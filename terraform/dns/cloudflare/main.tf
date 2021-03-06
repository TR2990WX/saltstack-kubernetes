provider "cloudflare" {
  version = "~> 1.0"
  email = "${var.email}"
  token = "${var.token}"
}

resource "cloudflare_record" "hosts" {
  count = "${var.dns_count}"

  domain  = "${var.domain}"
  name    = "${element(var.hostnames, count.index)}"
  value   = "${element(var.public_ips, count.index)}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "domain" {
  domain  = "${var.domain}"
  name    = "${var.domain}"
  value   = "${element(var.public_ips, 0)}"
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "wildcard" {
  depends_on = ["cloudflare_record.domain"]

  domain  = "${var.domain}"
  name    = "*"
  value   = "${element(var.public_ips, 0)}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "kubernetes" {
  depends_on = ["cloudflare_record.domain"]

  domain  = "${var.domain}"
  name    = "kubernetes"
  value   = "${var.domain}"
  type    = "CNAME"
  proxied = false
}