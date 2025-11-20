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

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "192.168.0.0/16"
}
