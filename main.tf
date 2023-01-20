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
  for_each                    = toset(["cb01", "cb02", "cb03","cb-index01","cb-index02","cb-as01","cb-as02"])
  name                        = "tf-elk-${each.key}"
  ami                         = data.aws_ami.amazon-2.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.cb_nodes.id, aws_security_group.allow_tls.id]
  subnet_id                   = aws_subnet.tf_main_cb.id
iam_instance_profile = "EC2RoleForSSMandS3"
  tags      = {
    Terraform   = "true"
    Environment = "dev"
  }
  user_data = "${file("user-data-cb.sh")}"
}
##Couchbase Index Nodes
#module "ec2_instance"  {
#  source                      = "terraform-aws-modules/ec2-instance/aws"
#  version                     = "~> 3.0"
#  associate_public_ip_address = true
#  for_each                    = toset(["cb01-index", "cb02-index"])
#  name                        = "tf-cb-index-${each.key}"
#  ami                         = data.aws_ami.amazon-2.id
##  instance_type               = var.instance_type
#  instance_type               = "m5d.2xlarge"
#  key_name                    = var.ssh_key
#  monitoring                  = true
#  vpc_security_group_ids      = [aws_security_group.cb_nodes.id, aws_security_group.allow_tls.id]
#  subnet_id                   = aws_subnet.tf_main_cb.id
#
#  tags      = {
#    Terraform   = "true"
#    Environment = "dev"
#  }
#  user_data = "${file("user-data-cb.sh")}"
#}

#t3.xlarge
#ETL node. Use that one for importing data.
resource "aws_ebs_volume" "cbdata_import" {
  availability_zone = "us-west-2a"
  size              = 200
  type = "gp3"
  tags = {
    Name = "EBS for Data Parse and Load"
  }
}

resource "aws_instance" "cbimport_server" {
  ami                         = var.ami_image
  instance_type               = "t3.xlarge"
  subnet_id                   = aws_subnet.tf_main_cb.id
  associate_public_ip_address = true
  key_name                    = var.ssh_key
  user_data = "${file("user-data-cb.sh")}"
  iam_instance_profile = "EC2RoleForSSMandS3"
  tags                        = {
    Name        = "tf-cb-cbimport"
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_security_group_ids      = [aws_security_group.cb_nodes.id, aws_security_group.allow_tls.id]
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.cbdata_import.id
  instance_id = aws_instance.cbimport_server.id
}