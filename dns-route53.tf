####################
# Private DNS Zone #
####################
resource "aws_route53_zone" "private_zone" {
  name = var.domain_name
  vpc {
    vpc_id = aws_vpc.tf_main_cb.id
  }
}

# Couchbase Nodes Private DNS
resource "aws_route53_record" "private" {
  zone_id  = aws_route53_zone.private_zone.zone_id
  for_each = toset(["cb01", "cb02", "cb03","cb-index01","cb-index02"])
  name     = each.key
  type     = "A"
  ttl      = "300"
  records  = [module.ec2_instance[each.key].private_ip]
}

###################
# Public DNS Zone #
###################
resource "aws_route53_zone" "public_zone" {
  name = var.domain_name
}
# Couchbase Nodes Public DNS
resource "aws_route53_record" "public_zone" {
  zone_id  = aws_route53_zone.public_zone.zone_id
  for_each = toset(["cb01", "cb02", "cb03","cb-index01","cb-index02"])
  name     = each.key
  type     = "A"
  ttl      = "300"
  records  = [module.ec2_instance[each.key].public_ip]
}