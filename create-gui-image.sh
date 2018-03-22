#!/bin/bash
export LIBGUESTFS_BACKEND=direct
qemu-img create -f qcow2 gui.qcow2 6G
cp xenial-server-cloudimg-amd64-disk-mod.img ubuntu-xenial.img
virt-resize --expand /dev/sda1 ubuntu-xenial.img gui.qcow2

chgrp -R libvirt /var/lib/libvirt/images
chmod g+rw /var/lib/libvirt/images

virt-customize -a gui.qcow2 \
--root-password password:juniper123 \
--hostname gui_host \
--run-command 'useradd ubuntu' \
--password ubuntu:password:juniper123 \
--run-command 'echo "ubuntu ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/ubuntu' \
--chmod 0440:/etc/sudoers.d/ubuntu \
--run-command 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config' \

cp gui.qcow2 /var/lib/libvirt/images/gui.qcow2

sudo virt-install --name gui-host --disk /var/lib/libvirt/images/gui.qcow2 --vcpus=1 --ram=2048 --network network=default,model=virtio --virt-type kvm --import  --graphics vnc --serial pty --noautoconsole --console pty,target_type=virtio
