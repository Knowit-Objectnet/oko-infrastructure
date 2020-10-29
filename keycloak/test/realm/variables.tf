variable "kc_client_secret" {
  type        = string
  description = "Client secret for keycloak terraform client"
}

variable "kc_url" {
  type        = string
  description = "URL for keycloak access"
}

variable "kc_client_id" {
  type        = string
  description = "Client ID for keycloak access"
  default     = "terraform"
}