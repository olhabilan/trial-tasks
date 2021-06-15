variable "region" {
  type        = string
  description = "The region that all AWS resources are deployed to."
}

variable "environment" {
  type        = string
  description = "Environment, e.g. 'prod', 'stage', 'dev' etc."
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation."
}

variable "instance_type" {
  default     = "m5.large"
  type        = string
  description = "The instance type associated with the EKS Node Group."
}

variable "asg_max_size" {
  default     = 2
  type        = number
  description = "The maximum size of the autoscale group."
}

variable "cluster_version" {
  default     = "1.20.4"
  type        = string
  description = "Desired Kubernetes master version."
}