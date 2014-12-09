#!/bin/bash -xe

if [ -z "${JOB_NAME##pipeline-*}" ]
then
    env=${JOB_NAME#pipeline-}
    env=${env%-*}
else
    env="{env}"
fi

export env
export KEY_NAME=combo
export cloud_provider=hp
chmod +x ./build_scripts/deploy.sh
./build_scripts/deploy.sh
