output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "app_subnet_ids" {
  description = "Application subnet IDs"
  value       = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.network.db_subnet_ids
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager secret ARN holding DB credentials"
  value       = module.rds.db_secret_arn
}

output "app_instance_id" {
  description = "Instance ID of the playground app EC2"
  value       = aws_instance.playground_app.id
}
