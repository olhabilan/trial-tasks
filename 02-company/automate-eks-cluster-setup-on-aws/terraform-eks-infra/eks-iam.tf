module "test_service_account_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.1.0"

  create_role = true

  role_name = "${local.id}-test-role-with-oidc"

  oidc_fully_qualified_subjects = ["system:serviceaccount:default:test-service-account"]

  tags = local.base_tags

  provider_url = module.eks_cluster.cluster_oidc_issuer_url

  role_policy_arns = [
    aws_iam_policy.test_service_account_policy.arn,
  ]
  number_of_role_policy_arns = 1
}

resource "aws_iam_policy" "test_service_account_policy" {
  name        = "test-service-account-policy"
  description = "A policy for test service account"
  policy      = data.aws_iam_policy_document.test_service_account_role_policy_document.json
}

data "aws_iam_policy_document" "test_service_account_role_policy_document" {
  statement {
    sid = "S3List"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::test-bucket"
    ]
  }

  statement {
    sid = "S3Access"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::test-bucket/*"
    ]
  }
}