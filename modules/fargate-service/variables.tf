variable "name" {
  type        = string
  description = "Base name of the resources created by this module."
}

variable "vpc_id" {
  type        = string
  description = "VPC to create theses resources in. "
}

variable "container_definitions" {
  type        = string
  description = "A string containing JSON formatted container definitions."
}

variable "cpu" {
  type        = number
  description = "Amount of CPU power each container should be allocated."
  default     = 256
}

variable "memory" {
  type        = number
  description = "Amount of memory each container should be allocated."
  default     = 512
}

variable "tags" {
  type        = map(string)
  description = "A map containing the tags the resource created by this module should have attached."
  default     = {}
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster to launch the service in."
}

variable "desired_count" {
  type        = number
  description = "Desired number of running containers."
  default     = 2
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of containers to run."
  default     = 4
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of containers to run."
  default     = 1
}

variable "container_name" {
  type        = string
  description = "Name of the container to load balance."
}

variable "container_port" {
  type        = number
  description = "Port of the container to load balance"
  default     = 80
}

variable "subnets" {
  type        = list(string)
  description = "A list of IDs of the subnets to launch the service in."
  default     = []
}

variable "security_groups" {
  type        = list(string)
  description = "A list of Security group IDs to attach to the service."
  default     = []
}

variable "health_check_path" {
  type        = string
  description = "Path the load balancer uses to check for node health."
  default     = "/health_check"
}

variable "lb_arn" {
  type        = string
  description = "ARN of the load balancer to use."
}

variable "lb_listener_port" {
  type        = number
  description = "Port that the load balancer listener will use."
}

variable "scale_up_threshold" {
  type        = string
  description = "CPUUtilization threshold in % before scaling up."
  default     = 85
}

variable "scale_down_threshold" {
  type        = string
  description = "CPUUtilization threshold in % before scaling down."
  default     = 10
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Namespace to use for service discovery"
}

variable "enable_code_deploy" {
  type        = bool
  description = "Wether to enable code deploy for blue green deployments."
  default     = true
}

variable "execution_role" {
  type        = string
  description = "Execution role of the ecs task."
  default     = null
}

variable "health_check_grace_period" {
  type        = number
  description = "Number of second to wait before starting to health check."
  default     = 0
}