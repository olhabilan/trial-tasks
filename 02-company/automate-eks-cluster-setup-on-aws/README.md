# Automate EKS cluster setup on AWS

You've joined a new and growing startup.

The company wants to build its initial Kubernetes infrastructure on AWS.

They have asked you if you can help create the following:

1. Terraform code that deploys an EKS cluster (whatever latest version is currently available) into an existing VPC
2. The terraform code should also prepare anything needed for a pod to be able to assume an IAM role
3. Include a short readme that explains how to use the Terraform repo and that also demonstrates how an end-user (a developer from the company) can run a pod on this new EKS cluster and also have an IAM role assigned that allows that pod to access an S3 bucket.

## Prerequisites

We have an AWS account and there are VPC + network resources (subnets, security groups, nat gateway etc). All resources are tagged correspondingly.
The role `role/eks-system-role` should be assumable by users, who should have access to the cluster.

## Solution

### Terraform AWS EKS module

The most popular AWS EKS terraform module is chosen. The other solution can be Cloudposse module. Only the basic configuration is done for the module. The cluster version/number of node/instance type are adjustable. VPC ID/subnets IDs are got from data resources via tags. For EKS cluster creation used AWS provider with the additional role, which should be assumed to get k8s access.

### IAM roles for pods

The alternative for the used module is also the Cloudposse one, mentioned in Links below. The policy with S3 access is created. This module creates a single IAM role which can be assumed by trusted resources using OIDC Federated Users.
`oidc_fully_qualified_subjects` is used for tieing this role only for `test-service-account`, so any others k8s resources can't assume the role.

### The guide for developers

1. Install terraform v1.0.0
2. Apply terraform scripts via running commands:
```
terraform init
terraform apply
```
There will be outputs of cluster name, assumable role arn, service account role arn.
3. Configure access to the created k8s cluster:
```
aws eks --region $AWS_REGION update-kubeconfig --name $TF_OUTPUT_cluster_name --role-arn=$TF_OUTPUT_eks_assume_role_arn"
```
4. Create service account for the pod using this config:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-service-account
  annotations:
    eks.amazonaws.com/role-arn: $TF_OUTPUT_test_sa_role_arn
```
Then create a pod which refers to this service account:
```
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  serviceAccountName: test-service-account
  ...
```
Then you should be able to work with `test-bucket` S3 bucket inside the created pod.

## Links

[terraform-aws-eks] https://github.com/terraform-aws-modules/terraform-aws-eks

[cloudposse-terraform-aws-eks] https://github.com/cloudposse/terraform-aws-eks-cluster

[terraform-aws-iam] https://github.com/terraform-aws-modules/terraform-aws-iam

[cloudposse-terraform-aws-iam] https://github.com/cloudposse/terraform-aws-eks-iam-role

[terraform-downloads] https://www.terraform.io/downloads.html

[configure-service-account-for-pod] https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/