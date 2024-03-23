resource "tls_private_key" "trustanchor_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}


resource "tls_self_signed_cert" "trustanchor_cert" {
  private_key_pem       = tls_private_key.trustanchor_key.private_key_pem
  validity_period_hours = 876000
  is_ca_certificate     = true

  subject {
    common_name = "root.linkerd.cluster.local"
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
}

resource "tls_private_key" "webhook_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

module "release" {
  source  = "terraform-module/release/helm"
  version = "2.8.2"
  # insert the 3 required variables here
  namespace  = "linkerd"
  repository = "https://logscale-contrib.github.io/helm-linkerd-trust-anchor"
  app = {
    chart   = "linkerd2-trust-anchor"
    version = "2.0.1"
    name    = "cw-trust-anchor"
    deploy  = 1
  }
  values = [yamlencode(
    {
      "tls" = {
        "crt" = tls_self_signed_cert.trustanchor_cert.cert_pem
        "key" = tls_private_key.trustanchor_key.private_key_pem
      }
    }
  )]
}
