resource "tls_self_signed_cert" "services_alb_certificate" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.services_alb_key.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
    organizational_unit = "Kubernetes"
    locality = "London"
    province = "London"
    country = "GB"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "services_alb_key" {
  algorithm   = "RSA"
}

resource "aws_acm_certificate" "services_alb_acm_certificate" {
  private_key      = tls_private_key.services_alb_key.private_key_pem
  certificate_body = tls_self_signed_cert.services_alb_certificate.cert_pem
  tags = {
    Name = "terrakube-services-alb-cert"
  }
}