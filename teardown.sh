#!/bin/bash -ex

if [ -z "${JOB_NAME##pipeline-*}" ]
then
    env=${JOB_NAME#pipeline-}
    env=${env%-*}
else
    env="{env}"
fi

export env

. /var/lib/jenkins/cloud.${env}.env

rm -rf venv

virtualenv venv
. venv/bin/activate
pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud

#python -m jiocloud.apply_resources delete test${deploy_id}
