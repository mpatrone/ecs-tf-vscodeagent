output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group for app tasks"
  value       = aws_lb_target_group.app.arn
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_listener_https_arn" {
  description = "The ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}