terraform {
  required_providers {
    keycloak = {
      source        = "mrparkers/keycloak"
      version       = "= 2.0.0"
    }
  }
}

provider "keycloak" {
  client_id     = var.kc_client_id
  client_secret = var.kc_client_secret
  url           = var.kc_url
}

resource "keycloak_realm" "test" {
  realm             = "test"
  enabled           = true
  display_name      = "test"
  display_name_html = "test"

  login_theme = "keycloak"

  password_policy = "length(12) and notUsername and passwordHistory(3)"

  registration_allowed   = true
  reset_password_allowed = true
  remember_me            = true
  ssl_required           = "external"


  internationalization {
    supported_locales = [
      "en",
      "no"
    ]
    default_locale = "no"
  }

  security_defenses {
    headers {
      x_frame_options                     = "DENY"
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                = false
      max_login_failures               = 5
      wait_increment_seconds           = 60
      quick_login_check_milli_seconds  = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds         = 900
      failure_reset_time_seconds       = 43200
    }
  }


}