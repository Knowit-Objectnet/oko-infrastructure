variable "vpc_id" {
  type        = string
  description = "VPC to deploy the project to"
  default     = "vpc-07217bf6b8064c913"
}

variable "environment" {
  type        = string
  description = "What environment to deploy"
  default     = "production"
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


variable "lb_port" {
  type        = number
  description = "Which port to use for the load balancer listener"
  default     = 8085
}
