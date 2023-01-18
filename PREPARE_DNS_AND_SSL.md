# Import Route 53 Zone in TF

Chances are that the DNS zone is already created and that we would need to import it into our new project from where we would manage the DNS names for the servers.
We would use the steps from this blogpost:
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


# Prepare Server Certificates Configure Couchbase to use them
This step is optional and will be executed manually.
We will follow the steps outlined in the official documentation
[https://docs.couchbase.com/server/current/manage/manage-security/configure-server-certificates.html](https://docs.couchbase.com/server/current/manage/manage-security/configure-server-certificates.html)

We will generate a multi-domain SSL certificate via acme.sh from lets encrypt
[https://letsencrypt.org/docs/client-options/](https://letsencrypt.org/docs/client-options/)
and will deploy the client certificates to some of the nodes that we will be connecting via web-console.
```shell
acme.sh --issue --dns dns_aws -d cb01.example.com -d cb02.example.com -d cb03.example.com -d cb-index01.example.com  -d cb-index02.example.com -d cb03.example.com
```

The final output from the command above would look be something this
```shell
[Sat Dec 24 07:26:18 PM CST 2022] Your cert is in  /home/ec2-user/.acme.sh/cb01.example.com/cb01.example.com.cer 
[Sat Dec 24 07:26:18 PM CST 2022] Your cert key is in  /home/ec2-user/.acme.sh/cb01.example.com/cb01.example.com.key 
[Sat Dec 24 07:26:18 PM CST 2022] The intermediate CA cert is in  /home/ec2-user/.acme.sh/cb01.example.com/ca.cer 
[Sat Dec 24 07:26:18 PM CST 2022] And the full chain certs is there:  /home/ec2-user/.acme.sh/cb01.example.com/fullchain.cer 
```

If we run the command from the same host on which we already installed couchbase then simply will execute the following commands. 
```shell
cp /home/ec2-user/.acme.sh/cb01.example.com/cb01.example.com.cer  /opt/couchbase/var/lib/couchbase/inbox/chain.pem
cp /home/ec2-user/.acme.sh/cb01.example.com/cb01.example.com.key  /opt/couchbase/var/lib/couchbase/inbox/pkey.key
mkdir /opt/couchbase/var/lib/couchbase/inbox/CA
/home/ec2-user/.acme.sh/cb01.example.com/ca.cer  /opt/couchbase/var/lib/couchbase/inbox/CA/
curl -X POST http://127.0.0.1:8091/node/controller/loadTrustedCAs -u $cb_user:$cb_pass
curl -X POST http://127.0.0.1:8091/node/controller/reloadCertificate -u $cb_user:$cb_pass
```

It would be better if we keep the generated certificates in an S3 bucket. Then the commands for installing the Server certificates would look like this:
```shell
mkdir /opt/couchbase/var/lib/couchbase/inbox/
aws s3 cp s3://mrf-cb-sample/certs/cb01.example.com.cer  /opt/couchbase/var/lib/couchbase/inbox/chain.pem
aws s3 cp s3://mrf-cb-sample/certs/cb01.example.com.key  /opt/couchbase/var/lib/couchbase/inbox/pkey.key
mkdir /opt/couchbase/var/lib/couchbase/inbox/CA
 
aws s3 cp s3://mrf-cb-sample/certs/ca.cer  /opt/couchbase/var/lib/couchbase/inbox/CA/
curl -X POST http://127.0.0.1:8091/node/controller/loadTrustedCAs -u $cb_user:$cb_pass
curl -X POST http://127.0.0.1:8091/node/controller/reloadCertificate -u $cb_user:$cb_pass

``` 
