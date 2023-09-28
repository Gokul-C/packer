#boot_command=["<enter><wait><enter><f6><esc><wait> ","autoinstall<wait>"," cloud-config-url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/user-data<wait>"," ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'","<wait5><enter>"]
#boot_command=["<esc><esc><esc><esc>e<wait>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","<del><del><del><del><del><del><del><del>","linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/user-data\"<enter><wait>","initrd /casper/initrd<enter><wait>","boot<enter>","<enter><f10><wait>"]
boot_command=["c<wait>","linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"","<enter><wait>","initrd /casper/initrd","<enter><wait>","boot","<enter>"]
disk_additional_size=["150000"]
disk_size="70000"
http_directory="http"
iso_checksum_type="sha256"
iso_checksum="a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
iso_url="https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
output_directory="output-ubuntu2204"
#output_vagrant="./vbox/packer-ubuntu2204-g2.box"
provision_script_options="-z false -h true -p false"
ssh_password="ubuntu"
ssh_username="ubuntu"
switch_name="packer-hyperv-iso"
#vagrantfile_template="./vagrant/hv_ubuntu2204_g2.template"
vlan_id=""
vm_name="packer-ubuntu2204-g2"
uefi_file="./Boot-scripts/uefi.sh"
provision_file="./Boot-scripts/provision.sh"
motd_file="./Boot-scripts/motd.sh"
zeroing_file="./Boot-scripts/zeroing.sh"
neofetch_file="./Boot-scripts/prepare_neofetch.sh"