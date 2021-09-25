#!/bin/bash
THT=/usr/share/openstack-tripleo-heat-templates/
CNF=~/templates

DATE=$(date +%Y%m%d-%H%M)

echo "Dumping undercloud database..."
mkdir -p /home/stack/backupDB/

# get the mysql root password
MYSQL_ROOT=$(sudo hiera -c /etc/puppet/hiera.yaml mysql::server::root_password)

sudo podman exec mysql /usr/bin/mysqldump -uroot -p${MYSQL_ROOT} --all-databases --quick --single-transaction | gzip > /home/stack/backupDB/$(date +dump-database-%Y-%m-%d_%T.sql.gz)

echo "Starting deployment..."
sleep 3s

source ~/stackrc
openstack overcloud deploy --templates $THT \
-r $CNF/environments/roles_data.yaml \
-n $CNF/environments/network_data.yaml \
-e $THT/environments/network-isolation.yaml \
-e $THT/environments/ceph-ansible/ceph-ansible.yaml \
-e $THT/environments/disable-telemetry.yaml \
-e $CNF/environments/network-environment.yaml \
-e $CNF/environments/net-bond-with-vlans.yaml \
-e $CNF/environments/fencing.yaml \
-e ~/containers-prepare-parameter.yaml \
-e $CNF/environments/node-info.yaml \
-e $CNF/environments/ceph-config.yaml \
-e $CNF/environments/custom-domain.yaml \
{% if enable_tls is sameas true %}
-e $CNF/environments/enable-tls.yaml \
-e $CNF/environments/inject-trust-anchor.yaml \
-e $THT/environments/ssl/tls-endpoints-public-dns.yaml \
{% endif %}
-e $CNF/environments/HostnameMap.yaml \
-e $CNF/environments/fix-nova-reserved-host-memory.yaml 2>&1 | tee -a /home/stack/overcloud-install-$DATE.log

RETVALUE=$?
exit $RETVALUE

