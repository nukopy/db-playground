variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to resource names."
  type        = string
  default     = "playground-dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "azs" {
  description = "Availability zones to use (minimum 2 to reserve capacity)."
  type        = list(string)
}

variable "app_private_subnet_cidrs" {
  description = "CIDR blocks for application private subnets."
  type        = list(string)
}

variable "db_private_subnet_cidrs" {
  description = "CIDR blocks for database private subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (optional)."
  type        = list(string)
  default     = []
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for outbound internet access."
  type        = bool
  default     = false
}

variable "app_instance_type" {
  description = "EC2 instance type for the application node."
  type        = string
  default     = "t2.nano"
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Engine version for MySQL."
  type        = string
  default     = "8.0.36"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for RDS."
  type        = bool
  default     = false
}

variable "db_master_username" {
  description = "Master username for the database."
  type        = string
  default     = "app_admin"
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "db-playground"
  }
}
