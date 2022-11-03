data "aws_instance" "this" {
  filter {
    name   = "instance-id"
    values = [var.instance_id]
  }
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_route53_zone" "this" {
  zone_id = var.zone_id
}