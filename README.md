Terraform For Couchbase Cluster deployment

[https://earthly.dev/blog/terraform-route53/](https://earthly.dev/blog/terraform-route53/)
Import Private DNS Zone
```shell
terraform import aws_route53_zone.private_zone Z0804333XLBETX6UGMYZ
aws_route53_zone.private_zone: Importing from ID "Z0804333XLBETX6UGMYZ"...
aws_route53_zone.private_zone: Import prepared!
  Prepared aws_route53_zone for import
aws_route53_zone.private_zone: Refreshing state... [id=Z0804333XLBETX6UGMYZ]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```
Import Public DNS Zone
```shell
 terraform import aws_route53_zone.public_zone  Z0216218BVXFGLMIL118
aws_route53_zone.public_zone: Importing from ID "Z0216218BVXFGLMIL118"...
aws_route53_zone.public_zone: Import prepared!
  Prepared aws_route53_zone for import
aws_route53_zone.public_zone: Refreshing state... [id=Z0216218BVXFGLMIL118]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

```shell
curl -k -X GET https://cb01.example.com:18091/settings/security -u Administrator:passwordString | jq '.'
```
Import Route 53 Zone in TF
[https://www.daniloaz.com/en/how-to-quickly-import-all-records-from-a-route53-dns-zone-into-terraform/](https://www.daniloaz.com/en/how-to-quickly-import-all-records-from-a-route53-dns-zone-into-terraform/)

[Sat Dec 24 07:26:18 PM CST 2022] Your cert is in  /home/mnm/.acme.sh/cb01.example.com/cb01.example.com.cer 
[Sat Dec 24 07:26:18 PM CST 2022] Your cert key is in  /home/mnm/.acme.sh/cb01.example.com/cb01.example.com.key 
[Sat Dec 24 07:26:18 PM CST 2022] The intermediate CA cert is in  /home/mnm/.acme.sh/cb01.example.com/ca.cer 
[Sat Dec 24 07:26:18 PM CST 2022] And the full chain certs is there:  /home/mnm/.acme.sh/cb01.example.com/fullchain.cer 

mkdir /opt/couchbase/var/lib/couchbase/inbox/
 
cp /home/mnm/.acme.sh/cb01.example.com/cb01.example.com.cer  /opt/couchbase/var/lib/couchbase/inbox/chain.pem
cp /home/mnm/.acme.sh/cb01.example.com/cb01.example.com.key  /opt/couchbase/var/lib/couchbase/inbox/pkey.key

mkdir /opt/couchbase/var/lib/couchbase/inbox/CA
/home/mnm/.acme.sh/cb01.example.com/ca.cer  /opt/couchbase/var/lib/couchbase/inbox/CA/

curl -X POST http://127.0.0.1:8091/node/controller/loadTrustedCAs -u Administrator:passwordString
curl -X POST http://127.0.0.1:8091/node/controller/reloadCertificate -u Administrator:passwordString

mkdir /opt/couchbase/var/lib/couchbase/inbox/
aws s3 cp s3://mrf-cb-sample/certs/cb01.example.com.cer  /opt/couchbase/var/lib/couchbase/inbox/chain.pem
aws s3 cp s3://mrf-cb-sample/certs/cb01.example.com.key  /opt/couchbase/var/lib/couchbase/inbox/pkey.key
mkdir /opt/couchbase/var/lib/couchbase/inbox/CA
 
aws s3 cp s3://mrf-cb-sample/certs/ca.cer  /opt/couchbase/var/lib/couchbase/inbox/CA/
curl -X POST http://127.0.0.1:8091/node/controller/loadTrustedCAs -u Administrator:passwordString
curl -X POST http://127.0.0.1:8091/node/controller/reloadCertificate -u Administrator:passwordString
 