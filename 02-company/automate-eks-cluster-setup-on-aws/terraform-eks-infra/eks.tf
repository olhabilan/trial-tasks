module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name    = "${local.id}-cluster"
  cluster_version = var.cluster_version
  subnets         = concat(local.private_subnet_ids, local.public_subnet_ids)
  vpc_id          = local.vpc_id

  worker_groups = [
    {
      instance_type = var.instance_type
      asg_max_size  = var.asg_max_size
    }
  ]

  tags = local.base_tags

  providers = {
    aws = aws.eks
  }
}