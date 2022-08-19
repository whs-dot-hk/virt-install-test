t=$(mktemp -d)
echo $t
curl -o $t/preseed.cfg https://www.debian.org/releases/bullseye/example-preseed.txt
cat <<EOF >> $t/preseed.cfg
d-i grub-installer/bootdev string default
d-i passwd/root-login boolean false
d-i passwd/user-fullname string whs
d-i passwd/user-password password magic
d-i passwd/user-password-again password magic
d-i passwd/username string whs
d-i preseed/late_command string apt-install openssh-server
popularity-contest popularity-contest/participate boolean false
tasksel tasksel/first multiselect standard
EOF
qemu-img create -f qcow2 test.qcow2 20G
virt-install \
  --disk test.qcow2 \
  --initrd-inject $t/preseed.cfg \
  --location https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/ \
  --memory 2048 \
  --name test \
  --network bridge:virbr0 \
  --os-variant debian11 \
  --vcpus 2 \
  ;
rm -rf $t
