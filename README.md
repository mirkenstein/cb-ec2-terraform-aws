# Terraform For Couchbase Cluster Deployment

This is set of TF templates is for deployment of infrastructure for  couchbase cluster.
The assumption is that we already have a DNS domain that is managed by AWS Route 53.
We will deploy total of 7 computes each of which will host an instance of couchbase server with the following roles
* 2 index nodes
* 3 data nodes 
* 2 Analytics nodes

We will use `m5d` [https://aws.amazon.com/ec2/instance-types/m5/](https://aws.amazon.com/ec2/instance-types/m5/) EC2 Type which have dedicated NVMe storage. We would use that for the data,index partitions of couchbase.

The final configuration of the nodes is done via Ansible playbooks and can be found here: [https://github.com/mirkenstein/cb-ansible-config](https://github.com/mirkenstein/cb-ansible-config)

To deploy simply run 
```shell
$ terraform apply
```
ToDo
Add to the userdata script the THP and Swap Space configurations
https://docs.couchbase.com/server/current/install/thp-disable.html
https://docs.couchbase.com/server/current/install/install-swap-space.html

