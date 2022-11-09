data "aws_instance" "this" {
  filter {
    name   = "instance-id"
    values = [var.instance_id]
  }
}

data "aws_network_interface" "this" {
  filter {
    name   = "attachment.instance-id"
    values = [var.instance_id]
  }
}

data "aws_subnet" "this" {
  id = data.aws_instance.this.subnet_id
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}

data "aws_internet_gateway" "this" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_route_table" "this" {
  filter {
    name   = "route.gateway-id"
    values = [data.aws_internet_gateway.this.internet_gateway_id]
  }

  filter {
    name   = "association.main"
    values = [true]
  }

  vpc_id = data.aws_vpc.this.id
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}