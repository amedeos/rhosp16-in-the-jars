#!/usr/bin/env bash
#
ANSIBLE_PLAYBOOK=$(which ansible-playbook)
VAULT_FILE=$1

#prepare images
echo "Run prepare-images"
$ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE --tags prepare-images main.yml
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in prepare-images"
    exit $retVal
fi

#create overcloud
echo "Run create-overcloud"
$ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE --tags create-overcloud main.yml
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in create-overcloud"
    exit $retVal
fi

#prepare undercloud
echo "Run prepare-undercloud"
$ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE --tags prepare-undercloud main.yml
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in prepare-undercloud"
    exit $retVal
fi

#install undercloud
echo "Run install-undercloud"
$ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE --tags install-undercloud main.yml
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in install-undercloud"
    exit $retVal
fi

#install overcloud
echo "Run install-overcloud"
$ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE --tags install-overcloud main.yml
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in install-overcloud"
    exit $retVal
fi

#fix ceph warn
echo "Run fix-ceph-warn"
$ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE --tags fix-ceph-warn main.yml
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in fix-ceph-warn"
    exit $retVal
fi

