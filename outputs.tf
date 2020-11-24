output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_alb.alb.dns_name
}

output "alb_name" {
  description = "The name of the ELB"
  value       = aws_alb.alb.name
}

output "alb_security_group_id" {
  description = "The security group ID of the ELB cluster"
  value       = aws_security_group.alb.id
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_alb.alb.zone_id
}

output "alb_backend" {
  description = "The target ARN of the ALB"
  value = aws_alb_target_group.backend.arn
}
