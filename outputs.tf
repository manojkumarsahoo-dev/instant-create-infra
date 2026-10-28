output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "frontend_subnet_ids" {
  value = [aws_subnet.frontend_1.id, aws_subnet.frontend_2.id]
}

output "backend_subnet_ids" {
  value = [aws_subnet.backend_1.id, aws_subnet.backend_2.id]
}

output "database_subnet_ids" {
  value = [aws_subnet.database_1.id, aws_subnet.database_2.id]
}

output "public_instance_id" {
  value = aws_instance.public_1.id
}

output "frontend_instance_id" {
  value = aws_instance.frontend_1.id
}

output "backend_instance_id" {
  value = aws_instance.backend_1.id
}

output "database_instance_id" {
  value = aws_instance.database_1.id
}

output "frontend_alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "frontend_application_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "internal_alb_dns_name" {
  value = aws_lb.internal.dns_name
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "nat_eip_address" {
  value = aws_eip.nat_eip.public_ip
}

output "ec2_ssm_role_name" {
  value = aws_iam_role.ec2_ssm_role.name
}
