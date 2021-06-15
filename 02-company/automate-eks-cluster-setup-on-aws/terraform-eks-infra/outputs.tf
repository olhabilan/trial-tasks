output "cluster_name" {
  value       = module.eks_cluster.cluster_id
  description = "The anme of the EKS cluster created for this environment."
}

output "eks_assume_role_arn" {
  value       = local.assume_role
  description = "The role arn used for EKS cluster creation."
}

output "test_sa_role_arn" {
  value       = module.test_service_account_role.iam_role_arn
  description = "The role arn of test ServiceAccount."
}