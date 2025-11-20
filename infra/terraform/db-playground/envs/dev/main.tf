provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  name_prefix                 = var.name_prefix
  region                      = var.aws_region
  vpc_cidr                    = var.vpc_cidr
  azs                         = var.azs
  app_private_subnet_cidrs    = var.app_private_subnet_cidrs
  db_private_subnet_cidrs     = var.db_private_subnet_cidrs
  public_subnet_cidrs         = var.public_subnet_cidrs
  create_nat_gateway          = var.create_nat_gateway
  enable_interface_endpoints  = true
  tags                        = var.tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix              = var.name_prefix
  db_subnet_ids            = module.network.db_subnet_ids
  db_security_group_ids    = [module.network.db_security_group_id]
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_class
  allocated_storage        = var.db_allocated_storage
  multi_az                 = var.db_multi_az
  master_username          = var.db_master_username
  storage_type             = "gp3"
  backup_retention_period  = 1
  apply_immediately        = true
  enable_iam_auth          = true
  tags                     = var.tags
}

data "aws_ssm_parameter" "al2023_x86" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "app" {
  name = "${var.name_prefix}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name_prefix}-app-profile"
  role = aws_iam_role.app.name
}

resource "aws_instance" "playground_app" {
  ami                         = data.aws_ssm_parameter.al2023_x86.value
  instance_type               = var.app_instance_type
  subnet_id                   = module.network.app_subnet_ids[0]
  vpc_security_group_ids      = [module.network.app_security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app"
  })
}
