#!/bin/bash -ex

. /var/lib/jenkins/cloud.{env}.env

if [ -n "${{fail_immediately}}" ]
then
    exit 1
fi

if ! [ -e venv ]
then
    virtualenv venv
    . venv/bin/activate
    pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud
    deactivate
fi

. venv/bin/activate

ip=$(python -m jiocloud.utils get_ip_of_node etcd1_test${{deploy_id}})

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no jenkins@${{ip}} true
