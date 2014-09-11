#!/bin/bash -xe

. /var/lib/jenkins/cloud.{env}.env

if ! [ -e venv ]
then
    virtualenv venv
    . venv/bin/activate
    pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud
    deactivate
fi

. venv/bin/activate

if [ -z "${{etcd_discovery_token}}" ]
then
    etcd_discovery_token=$(python -m jiocloud.orchestrate new_discovery_token)
fi

bash userdata.sh -t "${{etcd_discovery_token}}" > userdata.txt

python -m jiocloud.apply_resources apply --key_name=soren --project_tag=test${{BUILD_NUMBER}} environment/cloud.{env}.yaml userdata.txt

if [ -n "$floating_ip" ]
then
	nova floating-ip-associate etcd1_test${{BUILD_NUMBER}} ${{floating_ip}}
fi

ip=$(python -m jiocloud.utils get_ip_of_node etcd1_test${{BUILD_NUMBER}})

timeout 600 bash -c "while ! python -m jiocloud.orchestrate --host ${{ip}} ping; do sleep 5; done"

timeout 600 bash -c "while ! ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no jenkins@${{ip}} python -m jiocloud.orchestrate trigger_update ${{BUILD_NUMBER}}; do sleep 5; done"

timeout 600 bash -c "while ! python -m jiocloud.apply_resources list --project_tag=test${{BUILD_NUMBER}} environment/cloud.{env}.yaml | sed -e 's/_/-/g' | python -m jiocloud.orchestrate --host ${{ip}} verify_hosts ${{BUILD_NUMBER}} ; do sleep 5; done"
timeout 600 bash -c "while ! python -m jiocloud.orchestrate --host ${{ip}} check_single_version -v ${{BUILD_NUMBER}} ; do sleep 5; done"
