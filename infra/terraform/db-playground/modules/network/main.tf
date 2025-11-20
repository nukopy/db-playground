terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
}

locals {
  base_tags = merge(
    {
      "ManagedBy" = "Terraform"
      "Component" = var.name_prefix
    },
    var.tags
  )

  create_public_subnets = length(var.public_subnet_cidrs) > 0
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  count = local.create_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "app" {
  for_each = { for idx, az in var.azs : idx => {
    az   = az
    cidr = element(var.app_private_subnet_cidrs, idx)
  } }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-app-${each.value.az}"
    Tier = "app"
  })
}

resource "aws_subnet" "db" {
  for_each = { for idx, az in var.azs : idx => {
    az   = az
    cidr = element(var.db_private_subnet_cidrs, idx)
  } }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-db-${each.value.az}"
    Tier = "db"
  })
}

resource "aws_subnet" "public" {
  for_each = local.create_public_subnets ? { for idx, az in var.azs : idx => {
    az   = az
    cidr = element(var.public_subnet_cidrs, idx)
  } } : {}

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-public-${each.value.az}"
    Tier = "public"
  })
}

resource "aws_eip" "nat" {
  count = var.create_nat_gateway && local.create_public_subnets ? 1 : 0

  domain = "vpc"

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway && local.create_public_subnets ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count = local.create_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  count = local.create_public_subnets ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = local.create_public_subnets ? aws_subnet.public : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-app-rt"
  })
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route" "app_nat" {
  count = var.create_nat_gateway && local.create_public_subnets ? 1 : 0

  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-db-rt"
  })
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Application tier security group"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Database tier security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description              = "MySQL from app tier"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_groups          = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-db-sg"
  })
}

resource "aws_security_group" "endpoint" {
  count = var.enable_interface_endpoints ? 1 : 0

  name        = "${var.name_prefix}-vpce-sg"
  description = "Security group for interface VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "Allow HTTPS from app subnets"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-vpce-sg"
  })
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_interface_endpoints ? toset(var.interface_endpoint_services) : []

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = var.enable_interface_endpoints ? [aws_security_group.endpoint[0].id] : []
  private_dns_enabled = true

  tags = merge(local.base_tags, {
    Name = "${var.name_prefix}-vpce-${each.value}"
  })
}
