output "trustAnchorPEM" {
    value = tls_self_signed_cert.trustanchor_cert.cert_pem
}
