# Fargate service

This module specifies everything needed to setup a fargate service on an existing cluster based on a provided task definition.

The bellow ouptut is generated with [terraform-docs](https://github.com/segmentio/terraform-docs)
## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | name of the cluster to launch the service in. | `string` | n/a | yes |
| container\_definitions | A string containing JSON formatted container definitions. | `string` | n/a | yes |
| container\_name | Name of the container to load balance. | `string` | n/a | yes |
| container\_port | Port of the container to load balance | `number` | `80` | no |
| cpu | Amount of CPU power each container should be allocated. | `number` | `256` | no |
| desired\_count | Desired number of running containers. | `number` | `2` | no |
| enable\_code\_deploy | Wether to enable code deploy for blue green deployments. | `bool` | `true` | no |
| execution\_role | Execution role of the ecs task. | `string` | `null` | no |
| health\_check\_grace\_period | Number of second to wait before starting to health check. | `number` | `0` | no |
| health\_check\_path | Path the load balancer uses to check for node health. | `string` | `"/health_check"` | no |
| lb\_arn | ARN of the load balancer to use. | `string` | n/a | yes |
| lb\_listener\_port | Port that the load balancer listener will use. | `number` | n/a | yes |
| max\_capacity | Maximum number of containers to run. | `number` | `4` | no |
| memory | Amount of memory each container should be allocated. | `number` | `512` | no |
| min\_capacity | Minimum number of containers to run. | `number` | `1` | no |
| name | Base name of the resources created by this module. | `string` | n/a | yes |
| scale\_down\_threshold | CPUUtilization threshold in % before scaling down. | `string` | `10` | no |
| scale\_up\_threshold | CPUUtilization threshold in % before scaling up. | `string` | `85` | no |
| security\_groups | A list of Security group IDs to attach to the service. | `list(string)` | `[]` | no |
| service\_discovery\_namespace\_id | Namespace to use for service discovery | `string` | n/a | yes |
| subnets | A list of IDs of the subnets to launch the service in. | `list(string)` | `[]` | no |
| tags | A map containing the tags the resource created by this module should have attached. | `map(string)` | `{}` | no |
| vpc\_id | VPC to create theses resources in. | `string` | n/a | yes |

## Outputs

No output.