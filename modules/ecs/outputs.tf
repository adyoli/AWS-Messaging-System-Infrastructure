output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "ecs_service_sg_id" {
  description = "The ID of the ECS service security group."
  value       = aws_security_group.ecs_service_sg.id
}