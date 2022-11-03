output "certificate_arn" {
  description = "AWS ARN of the ACM Certificate used to expose the application public endpoint"
  value       = try(aws_acm_certificate.this.arn, "")
}

output "alb_arn" {
  description = "AWS ARN for the AWS application Load Balancer created to expose the application public endpoint."
  value       = try(aws_lb.this.arn, "")
}

output "alb_dns_name" {
  description = "DNS Name for the AWS Application Load Balancer created to expose the application public endpoint"
  value       = try(aws_lb.this.dns_name, "")
}

output "public_url" {
  description = "URL where the application can be reached."
  value       = try("https://${aws_route53_record.alb_record.fqdn}", "")
}