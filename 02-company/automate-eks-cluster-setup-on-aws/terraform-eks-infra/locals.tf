locals {
  id = "${var.namespace}-${var.environment}"

  account_id  = data.aws_caller_identity.current.account_id
  assume_role = "arn:aws:iam::${local.account_id}:role/eks-system-role"

  base_tags = {
    Namespace          = var.namespace
    Environment        = var.environment
    ManagedByTerraform = true
    TerraformPRoject   = "eks_infra"
  }

  vpc_id             = data.aws_vpc.selected.id
  public_subnet_ids  = data.aws_subnet_ids.public.ids
  private_subnet_ids = data.aws_subnet_ids.private.ids
}