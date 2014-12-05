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

if [ -n "${fail_immediately}" ]
then
    exit 1
fi

rm -rf venv

virtualenv venv
. venv/bin/activate
pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud

python -m jiocloud.apply_resources ssh_config --project_tag=test${deploy_id} environment/cloud.${env}.yaml > ssh_config

ssh -F ssh_config -l jenkins oc1_{env} '. <(sudo cat /root/openrc) ; glance image-list'
