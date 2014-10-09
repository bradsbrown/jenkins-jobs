#!/bin/bash -ex

. /var/lib/jenkins/cloud.{env}.env

rm -rf venv

virtualenv venv
. venv/bin/activate
pip install -e git+https://github.com/JioCloud/python-jiocloud#egg=jiocloud

python -m jiocloud.apply_resources delete test${{deploy_id}}
