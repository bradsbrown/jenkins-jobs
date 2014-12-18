#!/bin/bash -ex

if [ -z "${JOB_NAME##pipeline-*}" ]
then
    env=${JOB_NAME#pipeline-}
    env=${env%-*}
else
    env="{env}"
fi

export env
export cloud_provider=hp
BUILD_NUMBER=$deploy_id
chmod +x ./build_scripts/test.sh
build_scripts/test.sh
