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
    Name = "${var.tags_prefix}-vpc"
  }
}

# ------------------------------------------------------------
# Subnet for AZ A
# ------------------------------------------------------------

# Private Subnet for App (AZ A)
resource "aws_subnet" "private_subnet_app_az_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_a  # 10.0.1.0/24
  availability_zone       = var.az_a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags_prefix}-private-subnet-app-az-a"
  }
}

# local のみの場合、明示的なルート指定は不要
resource "aws_route_table" "private_subnet_app_az_a_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tags_prefix}-private-subnet-app-az-a-rtb"
  }
}

# サブネットへルートテーブルを関連付け
resource "aws_route_table_association" "private_subnet_app_az_a_rta" {
  subnet_id      = aws_subnet.private_subnet_app_az_a.id
  route_table_id = aws_route_table.private_subnet_app_az_a_rtb.id
}

# Private Subnet for DB (AZ A)
resource "aws_subnet" "private_subnet_db_az_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_b  # 10.0.2.0/24
  availability_zone       = var.az_a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags_prefix}-private-subnet-db-az-a"
  }
}

resource "aws_route_table" "private_subnet_db_az_a_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tags_prefix}-private-subnet-db-az-a-rtb"
  }
}

resource "aws_route_table_association" "private_subnet_db_az_a_rta" {
  subnet_id      = aws_subnet.private_subnet_db_az_a.id
  route_table_id = aws_route_table.private_subnet_db_az_a_rtb.id
}

# ------------------------------------------------------------
# Subnet for AZ B
# ------------------------------------------------------------

# Private Subnet for App (AZ B)
resource "aws_subnet" "private_subnet_app_az_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_c  # 10.0.3.0/24
  availability_zone       = var.az_b
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags_prefix}-private-subnet-app-az-b"
  }
}

resource "aws_route_table" "private_subnet_app_az_b_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tags_prefix}-private-subnet-app-az-b-rtb"
  }
}

resource "aws_route_table_association" "private_subnet_app_az_b_rta" {
  subnet_id      = aws_subnet.private_subnet_app_az_b.id
  route_table_id = aws_route_table.private_subnet_app_az_b_rtb.id
}

# Private Subnet for DB (AZ B)
resource "aws_subnet" "private_subnet_db_az_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_d  # 10.0.4.0/24
  availability_zone       = var.az_b
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags_prefix}-private-subnet-db-az-b"
  }
}

resource "aws_route_table" "private_subnet_db_az_b_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tags_prefix}-private-subnet-db-az-b-rtb"
  }
}

resource "aws_route_table_association" "private_subnet_db_az_b_rta" {
  subnet_id      = aws_subnet.private_subnet_db_az_b.id
  route_table_id = aws_route_table.private_subnet_db_az_b_rtb.id
}
