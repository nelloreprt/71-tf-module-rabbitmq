# for dev >> "${var.component}-${var.env}-${var.dns_domain}"
#   catalogue-dev-nellore.online  / cart-dev-nellore.online   / payment-dev-nellore.online

# but for prod FRONTEND will not be represented by environmet to environment
# but FRONTEND will represent whole environment
# i.e whole domain " nellore.online "  will represent PRODUCTION

locals {
  parameters = [ var.component ]
}