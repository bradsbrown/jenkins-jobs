#!/bin/bash -ex

if ! [ -e venv ]
then
    virtualenv venv
    . venv/bin/activate
    pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud
    deactivate
fi

. venv/bin/activate

ip=$(python -m jiocloud.utils get_ip_of_node etcd1)

python -m jiocloud.orchestrate --host ${{ip}} trigger_update ${{deploy_id}}

timeout 600 bash -c "while ! python -m jiocloud.orchestrate --host ${{ip}} check_single_version -v ${{deploy_id}}; do sleep 5; done"
