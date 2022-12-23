terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}
data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

#Couchbase Nodes
module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 3.0"
  associate_public_ip_address = true
  for_each                    = toset(["cb01", "cb02", "cb03"])
  name                        = "tf-elk-${each.key}"
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.cb_nodes.id, aws_security_group.allow_tls.id]
  subnet_id                   = aws_subnet.tf_main_cb.id

  tags      = {
    Terraform   = "true"
    Environment = "dev"
  }
  user_data = "${file("user-data-cb.sh")}"
}

