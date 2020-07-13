variable "vpc_id" {
  type        = string
  description = "VPC to deploy the project to"
}

variable "environment" {
  type        = string
  description = "What environment to deploy"
  default     = "production"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Namespace to use for service discovery"
}

variable "db_subnet_group" {
  type        = string
  description = "DB subnets"
}

variable "lb_port" {
  type = number
  description = "Which port to use for the load balancer listener"
  default = 8083
}

variable "cors_origin" {
  type = string
  description = "The allowed origin for CORS requests. Must be encased with single quotes"
  default = "'http://0.0.0.0:8080'"
}