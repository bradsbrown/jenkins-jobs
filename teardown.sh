#!/bin/bash -ex

if [ -z "${JOB_NAME##pipeline-*}" ]
then
    env=${JOB_NAME#pipeline-}
    env=${env%-*}
else
    env="{env}"
fi

export env
export cloud_provider=jio
BUILD_NUMBER=${deploy_id}
. ./build_scripts/common.sh

virtualenv venv
. venv/bin/activate
pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud

python -m jiocloud.apply_resources delete "${project_tag}"
