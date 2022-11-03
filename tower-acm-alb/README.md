# tower-acm-alb module

This module can be used to deploy a programmatic alb with ACM certificate. Pointing to a given ec2 instance, that will be running a tower installation.
Ideally, a tower installation inside the k3s cluster.

## Usage

The example below, will show how to create a public certificate, an external application load balancer, and configure one ec2 instance as a target for a target group, configuring the listener with the previously created certificate.

```hcl
## main.tf
module "tower-acm-alb" {
  source                        = "github.com/seqeralabs/terraform-modules//tower-acm-alb"
  record_name                   = "tower.example.com"
  alb_name                      = "tower-alb"
  domain_name                   = "example.com"
  zone_id                       = "ABCDEFG1234ABCDFG"
  instance_private_ip           = "172.31.37.61"
  instance_id                   = "i-01234abcd4321abc"
  vpc_id                        = "vpc-1234abc1234"
  public_subnets_id             = ["subnet-1234abc1234", "subnet-1234abc1234", "subnet-1234abc1234"]
  alb_delete_protection_enabled = false
  tags                          = {
    Terraform = "true"
    Application = "Tower"
  }
}
```

Terraform Plan:
```shell
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.tower-acm-alb.aws_acm_certificate.this will be created
  + resource "aws_acm_certificate" "this" {
  ...
  }

  # module.tower-acm-alb.aws_acm_certificate_validation.this will be created
  + resource "aws_acm_certificate_validation" "this" {
  ...
  }

  # module.tower-acm-alb.aws_lb.this will be created
  + resource "aws_lb" "this" {
  ...
  }
  # module.tower-acm-alb.aws_lb_listener.https will be created
  + resource "aws_lb_listener" "https" {
  ...
  }

  # module.tower-acm-alb.aws_lb_listener.http will be created
  + resource "aws_lb_listener" "http" {
  ...
  }

  # module.tower-acm-alb.aws_lb_target_group.this will be created
  + resource "aws_lb_target_group" "this" {
  ...
  }

  # module.tower-acm-alb.aws_lb_target_group_attachment.this will be created
  + resource "aws_lb_target_group_attachment" "this" {
  ...
  }

  # module.tower-acm-alb.aws_route53_record.alb_record will be created
  + resource "aws_route53_record" "alb_record" {
  ...
  }

  # module.tower-acm-alb.aws_route53_record.this["tower.staging-tower.xyz"] will be created
  + resource "aws_route53_record" "this" {
  ...
  }

  # module.tower-acm-alb.aws_security_group.alb_sg will be created
  + resource "aws_security_group" "alb_sg" {
  ...
  }

  # module.tower-acm-alb.aws_security_group.ec2_sg will be created
  + resource "aws_security_group" "ec2_sg" {
  ...
  }

Plan: 11 to add, 0 to change, 0 to destroy.
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.37.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.37.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_network_interface_sg_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_sg_attachment) | resource |
| [aws_route53_record.alb_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name for the AWS Aplication Load Balancer used to expose the EC2 instance running k3s. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name of the hosted zone that will be used for ACM certificate, and DNS records. | `string` | n/a | yes |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | The ID of the EC2 instance where k3s is running. | `string` | n/a | yes |
| <a name="input_instance_private_ip"></a> [instance\_private\_ip](#input\_instance\_private\_ip) | Private IP of the instance running the k3s cluster. | `string` | n/a | yes |
| <a name="input_public_subnets_id"></a> [public\_subnets\_id](#input\_public\_subnets\_id) | A list with a minimun of two public subnets where the AWS Application Load Balancer will be allocated. | `list(string)` | n/a | yes |
| <a name="input_record_name"></a> [record\_name](#input\_record\_name) | The dns record name that will be used to access the EC2 instance running k3s | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the EC2 instance running the k3s cluster is deployed. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Zone ID for the AWS Route53 Hosted zone that will be used for ACM certificate, and DNS records. | `string` | n/a | yes |
| <a name="input_alb_delete_protection_enabled"></a> [alb\_delete\_protection\_enabled](#input\_alb\_delete\_protection\_enabled) | Where to enabled or disable deletion protection for the AWS Application Load Balancer. | `bool` | `true` | no |
| <a name="input_alb_sg_ports"></a> [alb\_sg\_ports](#input\_alb\_sg\_ports) | AWS Security Group ports that will be exposed in the ALB. | `set(number)` | <pre>[<br>  80,<br>  443<br>]</pre> | no |
| <a name="input_ec2_sg_port"></a> [ec2\_sg\_port](#input\_ec2\_sg\_port) | Port where the EC2 instance running k3s cluster will expose the application. | `number` | `80` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | AWS ARN for the AWS application Load Balancer created to expose the application public endpoint. |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS Name for the AWS Application Load Balancer created to expose the application public endpoint |
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | AWS ARN of the ACM Certificate used to expose the application public endpoint |
| <a name="output_public_url"></a> [public\_url](#output\_public\_url) | URL where the application can be reached. |