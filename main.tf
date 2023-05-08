resource "aws_spot_instance_request" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_ids = var.subnet_ids[0] # we are creating only one_spot_instance, so we are attaching it to index_0 subnet_id.
  wait_for_fulfillment = "true"  # mandatory for spot_instances

  tags = merge(var.tags,
    { Name = "${var.env}-rabbitMq" })

  vpc_security_group_ids = [aws_security_group.main.id]

  # the file_userdata.sh will be converted into base64_format using the function "filebase64encode"
  # " ${path.module} " >>  the file_userdata.sh will be searched in the location "71-tf-module-app"
  # " templatefile " >> is another function to replace the variables
  user_data = filebase64encode(templatefile("${path.module}/userdata.sh" , {
    component = rabbitmq
    env       = var.env
  }) )

  # iam permissions to access parameters, using instance profile
  iam_instance_profile = "aws_iam_instance_profile.main.name"
}

resource "aws_ec2_tag" "spot_instance_tag" {
  key         = "name"
  resource_id = "aws_spot_instance_request.rabbitmq.spot_instace_id"
  value       = "rabbitmq-${var.env}"
}



# creating DNR Record for Payment
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.domain.zone_id  # input >> dns_domain = "nellore.online"
  name    = var.dns_name
  type    = "A"
  ttl     = 30

  # for creating A record >> private_ip is required
  records = [aws_spot_instance_request.rabbitmq.private_ip]  # input >> alb = "public"
}

#--------------------------------------------------------------------------

resource "aws_security_group" "main" {
  name        = "rabbitmq-${var.env}"
  description = "rabbitmq-${var.env}"
  vpc_id      = var.vpc_id    # vpc_id is coming from tf-module-vpc >> output_block

  # We need to open the Application port & we also need too tell to whom that port is opened
  # (i.e who is allowed to use that application port)
  # I.e shat port to open & to whom to open
  # Example for CTALOGUE we will open port 8080 ONLY WITHIN the APP_SUBNET
  # So that the following components (i.e to USER / CART / SHIPPING / PAYMENT) can use CATALOGUE.
  # And frontend also is necessarily need not be accessing the catalogue, i.e not to FRONTEND, because frontend belongs to web_subnet
  ingress {
    description      = "APP"
    from_port        = 5672   # rds port number
    to_port          = 5672   # rds port number
    protocol         = "tcp"
    cidr_blocks      = var.allow_subnets  # we want cidr number not subnet_id
  }

  ingress {
    description      = "SSH"
    from_port        = 22   # rds port number
    to_port          = 22   # rds port number
    protocol         = "tcp"
    cidr_blocks      = var.bastion_cidr  # we want cidr number not subnet_id ,
                                         # allowing bastion to ssh into rabbitmq
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    { Name = "rabbitmq-${var.env}" })
}
