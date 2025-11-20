variable "name_prefix" {
  description = "Prefix used for naming resources."
  type        = string
}

variable "region" {
  description = "AWS region (used for interface endpoint service names)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "List of availability zones to use."
  type        = list(string)
}

variable "app_private_subnet_cidrs" {
  description = "List of CIDR blocks for application private subnets (same order as azs)."
  type        = list(string)
}

variable "db_private_subnet_cidrs" {
  description = "List of CIDR blocks for database private subnets (same order as azs)."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Optional list of CIDR blocks for public subnets (same order as azs)."
  type        = list(string)
  default     = []
}

variable "create_nat_gateway" {
  description = "Whether to create a single NAT Gateway in the first public subnet."
  type        = bool
  default     = false
}

variable "enable_interface_endpoints" {
  description = "Create interface VPC endpoints for the specified services."
  type        = bool
  default     = true
}

variable "interface_endpoint_services" {
  description = "List of interface endpoint service short names to provision."
  type        = list(string)
  default     = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
    "secretsmanager"
  ]
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
