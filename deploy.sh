#!/bin/bash -xe

if [ -z "${{etcd_discovery_token}}" ]
then
    etcd_discovery_token=$(python -m jiocloud.orchestrate new_discovery_token)
fi

cat <<EOF >userdata.txt
#!/bin/bash
release="\$(lsb_release -cs)"
wget -O puppet.deb http://apt.puppetlabs.com/puppetlabs-release-\${{release}}.deb
dpkg -i puppet.deb
apt-get update
apt-get install -y puppet
apt-get install -y software-properties-common
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 85596F7A
add-apt-repository "deb http://jiocloud.rustedhalo.com/ubuntu/ \${{release}} main"
apt-get update
apt-get install puppet-jiocloud
sudo mkdir -p /etc/facter/facts.d
echo 'etcd_discovery_token='${{etcd_discovery_token}} > /etc/facter/facts.d/etcd.txt
puppet apply --debug -e "include rjil::jiocloud"
EOF

python -m jiocloud.apply_resources apply --key_name=soren --project_tag=test${{BUILD_NUMBER}} /var/lib/jenkins/cloud.{env}.yaml userdata.txt

if [ -n "$floating_ip" ]
then
	nova floating-ip-associate etcd1_test${{BUILD_NUMBER}} ${{floating_ip}}
fi

ip=$(python -m jiocloud.utils get_ip_of_node etcd1_test${{BUILD_NUMBER}})

timeout 600 bash -c "while ! python -m jiocloud.orchestrate --host ${{ip}} ping; do sleep 5; done"

timeout 600 bash -c "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no jenkins@${{ip}} python -m jiocloud.orchestrate trigger_update ${{BUILD_NUMBER}}" || true

timeout 600 bash -c "while ! python -m jiocloud.apply_resources list --project_tag=test${{BUILD_NUMBER}} /var/lib/jenkins/cloud.{env}.yaml | sed -e 's/_/-/g' | python -m jiocloud.orchestrate --host ${{ip}} verify_hosts ${{BUILD_NUMBER}} ; do sleep 5; done"
timeout 600 bash -c "while ! python -m jiocloud.orchestrate --host ${{ip}} check_single_version -v ${{BUILD_NUMBER}} ; do sleep 5; done"
