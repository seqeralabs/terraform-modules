## ACM

resource "aws_acm_certificate" "this" {
  domain_name       = var.record_name
  validation_method = "DNS"

  validation_option {
    domain_name       = var.record_name
    validation_domain = var.domain_name
  }

  tags = merge(
    var.tags,
  )
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}

resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets_id

  enable_deletion_protection = var.alb_delete_protection_enabled

  tags = merge(
    var.tags,
  )
}


## ALB
resource "aws_lb_target_group" "this" {
  name        = "tower-target-group"
  port        = var.ec2_sg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  tags = merge(
    var.tags,
  )
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.instance_id
  port             = var.ec2_sg_port
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(
    var.tags,
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(
    var.tags,
  )
}

## Route53
resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_route53_record" "alb_record" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

## Security Group
resource "aws_security_group" "alb_sg" {
  name = "tower_alb_sg"

  description = "Tower ALB Security Group"
  vpc_id      = var.vpc_id

  # Open Web ports on ALB
  dynamic "ingress" {
    for_each = var.alb_sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow outbound traffic to EC2 instance.
  egress {
    from_port   = var.ec2_sg_port
    to_port     = var.ec2_sg_port
    protocol    = "TCP"
    cidr_blocks = ["${var.instance_private_ip}/32"]
  }

  tags = merge(
    var.tags,
  )
}

resource "aws_security_group" "ec2_sg" {
  name = "tower_ec2_sg"

  description = "Tower ec2 instance Security Group"
  vpc_id      = var.vpc_id

  # Open application port on EC2 instance
  ingress {
    from_port       = var.ec2_sg_port
    to_port         = var.ec2_sg_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]

  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
  )
}