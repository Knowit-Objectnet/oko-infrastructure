variable "vpc_id" {
  type        = string
  description = "VPC to deploy the project to"
  default     = "vpc-07217bf6b8064c913"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Namespace to use for service discovery"
  default     = "ns-z4jxsxpbmv2dmwt7"
}

variable "db_subnet_group" {
  type        = string
  description = "DB subnets"
  default     = "ombruk-vpc-production"
}