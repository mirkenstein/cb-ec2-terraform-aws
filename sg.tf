resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf_main_cb.id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.tf_main_cb.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false

    },
    {
      description      = "HTTP from Everywhere"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false

    }, {
      description      = "SSH from Everywhere"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false

    }
  ]

  egress = [
    {
      description      = "TLS from VPC"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "tf_allow_tls"
  }
}

#Node-local only
#Unencrypted: 9119, 9998, 11213, 21200, 21300
#Encrypted: 21250 [1], 21350 [2]

#Node-to-node
#Unencrypted: 4369, 8091-8094, 9100-9105, 9110-9118, 9120-9122, 9130, 9999, 11209-11210, 21100
#Encrypted: 9999, 11206, 11207, 18091-18094, 19102, 19130, 21150

#Client-to-node
#Unencrypted: 8091-8097, 9123, 9140 [3], 11210, 11280
#Encrypted: 11207, 18091-18095, 18096, 18097

resource "aws_security_group" "cb_nodes" {
  name        = "couchbase_nodes"
  description = "Couchbase nodes "
  vpc_id      = aws_vpc.tf_main_cb.id

  ingress = [
    {
      description      = "Unencrypted Mode-to-Node"
      from_port        = 8091
      to_port          = 21350
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.tf_main_cb.cidr_block]
#      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    },
        {
      description      = "Encrypted Mode-to-Node"
      from_port        = 0
      to_port          = 65535
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.tf_main_cb.cidr_block]
#      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    },
     {
      description      = "Client Ports HTTPS "
      from_port        = 18091
      to_port          = 18097
      protocol         = "tcp"
      cidr_blocks      = ["73.246.73.171/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true

    }
    ,
     {
      description      = "Client Port Import HTTPS "
      from_port        = 11207
      to_port          = 11210
      protocol         = "tcp"
      cidr_blocks      = ["73.246.73.171/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true

    }
  ]

  egress = [
    {
      description      = "Egress Ports"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "tf_elk_es_nodes"
  }
}
