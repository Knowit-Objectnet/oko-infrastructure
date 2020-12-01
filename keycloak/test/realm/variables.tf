variable "kc_client_secret" {
  type        = string
  description = <<EOF
  Check the credentials tab for the keycloak client at
  https://keycloak.production.oko.knowit.no:8443/auth/
  If it doesn't exist, create one following this guide:
  https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs
  EOF
}

variable "kc_url" {
  type        = string
  description = "URL for keycloak access"
  default     = "https://keycloak.test.oko.knowit.no:8443"
}

variable "kc_client_id" {
  type        = string
  description = "Client ID for keycloak access"
  default     = "keycloak"
}