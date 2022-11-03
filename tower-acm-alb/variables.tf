## k3s instance IP
variable "instance_private_ip" {
  type        = string
  description = "Private IP of the instance running the k3s cluster."
}

## k3s instance ID
variable "instance_id" {
  type        = string
  description = "The ID of the EC2 instance where k3s is running."
}

## DNS Name associated with k3s instance
variable "record_name" {
  type        = string
  description = "The dns record name that will be used to access the EC2 instance running k3s"
}

## Route53 hosted zone domain name
variable "domain_name" {
  type        = string
  description = "The domain name of the hosted zone that will be used for ACM certificate, and DNS records."
}

variable "zone_id" {
  type        = string
  description = "Zone ID for the AWS Route53 Hosted zone that will be used for ACM certificate, and DNS records."
}

## ALB Security Group Ports
variable "alb_sg_ports" {
  type        = set(number)
  description = "AWS Security Group ports that will be exposed in the ALB."
  default     = [80, 443]
}

## EC2 Instance Security Group Ports
variable "ec2_sg_port" {
  type        = number
  description = "Port where the EC2 instance running k3s cluster will expose the application."
  default     = 80
}

## ALB Name
variable "alb_name" {
  type        = string
  description = "Name for the AWS Aplication Load Balancer used to expose the EC2 instance running k3s."
}

variable "alb_delete_protection_enabled" {
  type        = bool
  description = "Where to enabled or disable deletion protection for the AWS Application Load Balancer."
  default     = true
}

## Public subnets
variable "public_subnets_id" {
  type        = list(string)
  description = "A list with a minimun of two public subnets where the AWS Application Load Balancer will be allocated."
}

## VPC ID
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the EC2 instance running the k3s cluster is deployed."
}

## Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}