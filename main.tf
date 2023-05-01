resource "aws_spot_instance_request" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_ids = var.subnet_ids[0] # we are creating only one_spot_instance, so we are attaching it to index_0 subnet_id.
  wait_for_fulfillment = "true"  # mandatory for spot_instances

  tags = merge(var.tags,
    { Name = "${var.env}-rabbitMq" })
}