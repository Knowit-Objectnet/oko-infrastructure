variable "vpc_id" {
  type        = string
  description = "VPC to deploy the project to"
  default     = "vpc-0ba1f8f8a0df07997"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Namespace to use for service discovery"
  default     = "ns-r5stpprvemrylrga"
}

variable "db_subnet_group" {
  type        = string
  description = "DB subnets"
  default     = "ombruk-vpc-test"
}