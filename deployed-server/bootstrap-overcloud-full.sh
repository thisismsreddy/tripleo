#!/bin/bash

set -eux

sudo yum -y install git

git clone https://git.openstack.org/openstack-infra/tripleo-ci/ || :

tripleo-ci/scripts/tripleo.sh --repo-setup

# instack-undercloud will pull in all the needed deps
sudo yum -y install instack-undercloud

export ELEMENTS_PATH="/usr/share/diskimage-builder/elements:/usr/share/instack-undercloud:/usr/share/tripleo-image-elements:/usr/share/tripleo-puppet-elements:/usr/share/openstack-heat-templates/software-config/elements"

export DIB_INSTALLTYPE_puppet_modules=source

sudo -E instack \
  -e centos7 \
     overcloud-full \
     overcloud-controller \
     overcloud-compute \
     overcloud-ceph-storage \
     sysctl \
     hosts \
     baremetal \
     dhcp-all-interfaces \
     os-collect-config \
     heat-config-puppet \
     heat-config-script \
     puppet-modules \
     hiera \
     os-net-config \
     stable-interface-names \
     grub2 \
     dynamic-login \
     element-manifest \
     network-gateway \
     epel \
     enable-packages-install \
     pip-and-virtualenv-override \
     install-types \
  -k extra-data \
     pre-install \
     install \
     post-install \
  -b 05-fstab-rootfs-label \
     00-fix-requiretty \
     90-rebuild-ramdisk \
  -d

# Install additional packages expected by the image
sudo yum -y install \
  python-psutil \
  python-debtcollector \
  plotnetcfg \
  sos \
  python-networking-cisco \
  python-UcsSdk \
  device-mapper-multipath \
  python-networking-bigswitch \
  openstack-neutron-bigswitch-lldp \
  openstack-neutron-bigswitch-agent \
  python-zaqarclient

sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
sudo setenforce 0

sudo systemctl enable os-collect-config
