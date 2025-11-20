output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.this.id
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing credentials"
  value       = var.create_secret ? aws_secretsmanager_secret.master[0].arn : null
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
}
