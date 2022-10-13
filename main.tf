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
module "argohelm" {
  source        = "git@github.com:logscale-contrib/tf-self-managed-logscale-k8s-helm.git"
  repository    = "ghcr.io/logscale-contrib/helm-linkerd-trust-anchor/charts"
  release       = "cw-trust-anchor"
  chart         = "linkerd2-trust-anchor"
  chart_version = "1.0.6"
  namespace     = "linkerd"
  project       = "cluster-wide"

  values = yamlencode(
    {
      "tls" = {
        "crt" = tls_self_signed_cert.trustanchor_cert.cert_pem
        "key" = tls_private_key.trustanchor_key.private_key_pem
      }
    }
  )
}
