variable "env" {}

variable "tags" {}

variable "subnet_ids" {}

variable "instance_type" {}

variable "allow_subnets" {}
variable "vpc_id" {}

variable "bastion_cidr" {}
variable "dns_domain" {}

variable "component" {
  default = rabbitmq
}