output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "app_subnet_ids" {
  description = "IDs of application private subnets"
  value       = [for s in aws_subnet.app : s.id]
}

output "db_subnet_ids" {
  description = "IDs of database private subnets"
  value       = [for s in aws_subnet.db : s.id]
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "app_security_group_id" {
  description = "Security group ID for application tier"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security group ID for database tier"
  value       = aws_security_group.db.id
}

output "endpoint_security_group_id" {
  description = "Security group ID for interface endpoints"
  value       = var.enable_interface_endpoints ? aws_security_group.endpoint[0].id : null
}

output "interface_vpc_endpoint_ids" {
  description = "IDs of interface VPC endpoints"
  value       = var.enable_interface_endpoints ? [for ep in aws_vpc_endpoint.interface : ep.id] : []
}
