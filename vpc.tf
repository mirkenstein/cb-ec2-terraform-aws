resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tf_main_cb.id

  tags = {
    Name = "tf-main-gw"
  }
}

resource "aws_vpc" "tf_main_cb" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
    Name = "tf-main-cb-vpc"
  }
}
resource "aws_subnet" "tf_main_cb" {
  vpc_id     = aws_vpc.tf_main_cb.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-Main-cb-subnet"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.tf_main_cb.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      ipv6_cidr_block            = null
      gateway_id                 = aws_internet_gateway.gw.id
      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = null
      local_gateway_id           = null
      nat_gateway_id             = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
    }
  ]

  tags = {
    Name = "tf-example-route"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf_main_cb.id
  route_table_id = aws_route_table.example.id
}