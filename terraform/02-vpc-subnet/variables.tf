variable "profile" {
  description = "AWS profile name in ~/.aws/credentials"
  type        = string
  default     = "LearnTerraform"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "tags_prefix" {
  description = "Tags prefix"
  type        = string
  default     = "learn-terraform"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "192.168.0.0/16"
}

variable "az_a" {
  description = "Availability Zone A"
  type        = string
  default     = "ap-northeast-1a"
}

variable "private_subnet_cidr_a" {
  description = "Private Subnet CIDR 1st for AZ A"
  type        = string
  default     = "192.168.1.0/24"
}

variable "private_subnet_cidr_b" {
  description = "Private Subnet CIDR 2nd for AZ A"
  type        = string
  default     = "192.168.2.0/24"
}

variable "az_b" {
  description = "Availability Zone B"
  type        = string
}

variable "private_subnet_cidr_c" {
  description = "Private Subnet CIDR 1st for AZ B"
  type        = string
  default     = "192.168.3.0/24"
}

variable "private_subnet_cidr_d" {
  description = "Private Subnet CIDR 2nd for AZ B"
  type        = string
  default     = "192.168.4.0/24"
}
