variable "vpc_id" {
  type        = string
  description = "VPC to deploy the project to"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Namespace to use for service discovery"
}

variable "db_subnet_group" {
  type        = string
  description = "DB subnets"
}