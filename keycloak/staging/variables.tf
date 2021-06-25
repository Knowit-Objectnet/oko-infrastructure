variable "vpc_id" {
  type        = string
  description = "VPC to deploy the project to"
  default	  = "vpc-0e295a50d7280210a"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Namespace to use for service discovery"
  default	  = "ns-7etnpi4xtdvspdnm"
}

variable "db_subnet_group" {
  type        = string
  description = "DB subnets"
  default     = "ombruk-vpc-staging"
}