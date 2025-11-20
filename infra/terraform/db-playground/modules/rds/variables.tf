variable "name_prefix" {
  description = "Prefix used for naming RDS resources."
  type        = string
}

variable "db_subnet_ids" {
  description = "Subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "db_security_group_ids" {
  description = "List of security group IDs to attach to the RDS instance."
  type        = list(string)
}

variable "engine" {
  description = "Database engine."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "8.0.36"
}

variable "instance_class" {
  description = "Instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage (GiB)."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type for the RDS instance."
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups."
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Whether to apply modifications immediately."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = false
}

variable "enable_iam_auth" {
  description = "Enable IAM database authentication."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot when destroying the instance."
  type        = bool
  default     = true
}

variable "master_username" {
  description = "Master username for the database."
  type        = string
  default     = "app_admin"
}

variable "create_secret" {
  description = "Create a Secrets Manager secret for the master credentials."
  type        = bool
  default     = true
}

variable "secret_kms_key_id" {
  description = "Optional KMS key ID for encrypting the Secrets Manager secret."
  type        = string
  default     = null
}

variable "parameters" {
  description = "Custom parameters to set when creating a parameter group."
  type = map(object({
    value = string
  }))
  default = {}
}

variable "parameter_group_family" {
  description = "DB parameter group family (required if parameters are provided)."
  type        = string
  default     = null

  validation {
    condition     = length(var.parameters) == 0 || var.parameter_group_family != null
    error_message = "parameter_group_family must be set when parameters are provided."
  }
}

variable "tags" {
  description = "Additional tags to apply."
  type        = map(string)
  default     = {}
}

variable "database_name" {
  description = "Initial database name to create."
  type        = string
  default     = null
}

variable "identifier" {
  description = "Optional explicit DB instance identifier."
  type        = string
  default     = null
}
