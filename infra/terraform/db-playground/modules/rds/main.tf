terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

locals {
  tags = merge(
    {
      "ManagedBy" = "Terraform"
      "Component" = "${var.name_prefix}-rds"
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.db_subnet_ids

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "this" {
  count = length(var.parameters) > 0 ? 1 : 0

  name        = "${var.name_prefix}-db-params"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.name_prefix}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value.value
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-db-params"
  })
}

resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "_@#"
}

resource "aws_secretsmanager_secret" "master" {
  count = var.create_secret ? 1 : 0

  name        = "${var.name_prefix}-db-credentials"
  description = "Master credentials for ${var.name_prefix} RDS instance"
  kms_key_id  = var.secret_kms_key_id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-db-secret"
  })
}

resource "aws_secretsmanager_secret_version" "master" {
  count = var.create_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.master[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

resource "aws_db_instance" "this" {
  identifier = coalesce(var.identifier, "${var.name_prefix}-db")

  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  db_subnet_group_name = aws_db_subnet_group.this.name
  parameter_group_name  = length(var.parameters) > 0 ? aws_db_parameter_group.this[0].name : null

  vpc_security_group_ids = var.db_security_group_ids

  username = var.master_username
  password = random_password.master.result

  multi_az                      = var.multi_az
  backup_retention_period       = var.backup_retention_period
  apply_immediately             = var.apply_immediately
  performance_insights_enabled  = var.performance_insights_enabled
  iam_database_authentication_enabled = var.enable_iam_auth
  deletion_protection           = var.deletion_protection
  skip_final_snapshot           = var.skip_final_snapshot
  db_name                       = var.database_name

  lifecycle {
    ignore_changes = [password]
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-db"
  })

  depends_on = var.create_secret ? [aws_secretsmanager_secret_version.master] : []
}
