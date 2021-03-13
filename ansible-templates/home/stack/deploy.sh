#!/bin/bash
THT=/usr/share/openstack-tripleo-heat-templates/
CNF=~/templates

DATE=$(date +%Y%m%d-%H%M)

source ~/stackrc
openstack overcloud deploy --templates $THT \
-r $CNF/roles_data.yaml \
-n $CNF/network_data.yaml \
-e $THT/environments/network-isolation.yaml \
-e $THT/environments/ceph-ansible/ceph-ansible.yaml \
-e $THT/environments/disable-telemetry.yaml \
-e $CNF/environments/network-environment.yaml \
-e $CNF/environments/net-bond-with-vlans.yaml \
-e $CNF/fencing.yaml \
-e ~/containers-prepare-parameter.yaml \
-e $CNF/node-info.yaml \
-e $CNF/ceph-config.yaml \
-e $CNF/custom-domain.yaml \
{% if enable_tls is sameas true %}
-e $CNF/enable-tls.yaml \
-e $CNF/inject-trust-anchor.yaml \
{% endif %}
-e $CNF/fix-nova-reserved-host-memory.yaml 2>&1 | tee -a /home/stack/overcloud-install-$DATE.log

#-e $CNF/HostnameMap.yaml \

RETVALUE=$?
exit $RETVALUE

