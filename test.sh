#!/bin/bash -ex

ip=$(python -m jiocloud.utils get_ip_of_node etcd1_test${{deploy_id}})

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no jenkins@${{ip}} true
