data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  tags = {
    EKS         = "true"
    Environment = var.environment
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = local.vpc_id
  tags = {
    EKS         = "true"
    Environment = var.environment
    Type        = "private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = local.vpc_id
  tags = {
    EKS         = "true"
    Environment = var.environment
    Type        = "public"
  }
}