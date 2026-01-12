output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "api_instance_ips" {
  description = "Private IPs of API instances"
  value       = aws_instance.api[*].private_ip
}

output "load_balancer_instance_ip" {
  description = "Private IP of load balancer instance"
  value       = aws_instance.load_balancer.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "security_group_ids" {
  description = "Security group IDs"
  value       = [aws_security_group.alb.id, aws_security_group.ec2.id]
}
