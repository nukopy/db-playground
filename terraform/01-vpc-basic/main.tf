terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr            # 10.0.0.0/16
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "step01-vpc-basic"
  }
}
