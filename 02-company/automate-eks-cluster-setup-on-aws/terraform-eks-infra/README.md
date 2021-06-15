<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | 1.0.0 |
| aws | ~> 3.45.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.45.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| asg\_max\_size | The maximum size of the autoscale group. | `number` | `2` | no |
| cluster\_version | Desired Kubernetes master version. | `string` | `"1.20.4"` | no |
| environment | Environment, e.g. 'prod', 'stage', 'dev' etc. | `string` | n/a | yes |
| instance\_type | The instance type associated with the EKS Node Group. | `string` | `"m5.large"` | no |
| namespace | Namespace, which could be your organization name or abbreviation. | `string` | n/a | yes |
| region | The region that all AWS resources are deployed to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_name | The anme of the EKS cluster created for this environment. |
| eks\_assume\_role\_arn | The role arn used for EKS cluster creation. |
| test\_sa\_role\_arn | The role arn of test ServiceAccount. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->