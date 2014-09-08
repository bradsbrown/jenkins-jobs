#!/bin/bash -ex

. /var/lib/jenkins/cloud.{env}.env

if ! [ -e venv ]
then
    virtualenv venv
    . venv/bin/activate
    pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud
    deactivate
fi

. venv/bin/activate

python -m jiocloud.apply_resources delete test${{deploy_id}}
