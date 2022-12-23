#! /bin/bash
#amazon-linux-extras install -y  java-openjdk11
wget -O /tmp/couchbase-server-enterprise-7.1.3-amzn2.x86_64.rpm https://packages.couchbase.com/releases/7.1.3/couchbase-server-enterprise-7.1.3-amzn2.x86_64.rpm
yum install -y ncurses-compat-libs.x86_64
rpm -Uvh /tmp/couchbase-server-enterprise-7.1.3-amzn2.x86_64.rpm

sudo systemctl start couchbase-server.service
sudo systemctl enable couchbase-server.service
echo "The page was created by the user-data" | sudo tee /var/www/html/index.html

mkfs.xfs /dev/nvme1n1
mkdir /opt/data
echo "/dev/nvme1n1 /opt/data xfs defaults,nofail 0 2" >>/etc/fstab
mount -a
chown -R couchbase:couchbase /opt/data/