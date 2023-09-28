#!/usr/bin/env bash
# ubuntu version of provision.sh
INSTALL_UPDATES=true
INSTALL_PUPPET=true
INSTALL_HYPERV=false
INSTALL_COCKPIT=true
INSTALL_ZABBIX=false
STAMP_FILE="/etc/packerinfo"

usage() { echo "Usage: $0 [-u <true|false> INSTALL_UPDATES ] [-p <true|false> INSTALL_PUPPET] [-w <true|false> INSTALL_COCKPIT] [-h <true|false> INSTALL_HYPERV]  [-z <true|false> INSTALL_ZABBIX]" 1>&2; }

while getopts :u:p:h:w:z:  option
    do
      case "${option}"
      in
      u)
        INSTALL_UPDATES="${OPTARG}"
        ;;
      p)
        INSTALL_PUPPET="${OPTARG}"
        ;;
      h)
        INSTALL_HYPERV="${OPTARG}"
        ;;
      w)
        INSTALL_COCKPIT="${OPTARG}"
        ;;
      z)
        INSTALL_ZABBIX="${OPTARG}"
        ;;
      *)
        usage
        ;;
      esac
    done
echo "INSTALL_UPDATES = $INSTALL_UPDATES"
echo "INSTALL_COCKPIT = $INSTALL_COCKPIT"
echo "INSTALL_HYPERV  = $INSTALL_HYPERV"
echo "INSTALL_PUPPET  = $INSTALL_PUPPET"
echo "INSTALL_ZABBIX  = $INSTALL_ZABBIX"

echo "Provisioning phase 1 - Starting: Mirror, SELinux and basic packages"
export DEBIAN_FRONTEND=noninteractive
apt-get clean all -y
apt-get update -y
apt-get install pv perl mc net-tools -y

# set locale
sudo update-locale LANG=en_US.UTF-8

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 1 - system updates"
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y -q upgrade
    apt-get -y -q clean all
else
    echo "Provisioning phase 1 - skipping system updates"
fi

# disable selinux
echo "Provisioning phase 1 - disabling SELinux"
if [ -f /etc/sysconfig/selinux ]; then
  sed -i /etc/sysconfig/selinux -r -e 's/^SELINUX=.*/SELINUX=disabled/g'||true
fi

if [ -f /etc/selinux/config ]; then
  sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'||true
fi

echo "Provisioning phase 1 - all done"

echo "Provisioning phase 2 - Starting: Cockpit, Zabbix, Puppet"
# cockpit repository
if [ "$INSTALL_COCKPIT" == "true" ]; then
  echo "Provisioning phase 2 - Cockpit"
  export DEBIAN_FRONTEND=noninteractive
  systemctl preset cockpit.service
  systemctl preset cockpit.socket
  apt-get install cockpit -y -q
  systemctl enable cockpit.socket
  systemctl stop cockpit.socket

else
  echo "Provisioning phase 2 - skipping Cockpit"
fi

# zabbix
if [ "$INSTALL_ZABBIX" == true ]; then
  echo "Provisioning phase 2 - Zabbix"
# zabbix 6.0 repository
  export DEBIAN_FRONTEND=noninteractive
  wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-3+ubuntu22.04_all.deb
  dpkg -i zabbix-release_6.0-3+ubuntu22.04_all.deb
  rm -rfv zabbix-release_6.0-3+ubuntu22.04_all.deb
  apt-get update -y
  apt-get install zabbix-agent -y
  systemctl enable zabbix-agent
else
  echo "Provisioning phase 2 - skipping Zabbix agent"
fi

# puppet
if [ "$INSTALL_PUPPET" == "true" ]; then

    echo "Provisioning phase 2 - Puppet Agent"
    # puppet 7.x repository
    export DEBIAN_FRONTEND=noninteractive
    wget https://apt.puppet.com/puppet7-release-focal.deb
    dpkg -i puppet7-release-focal.deb
    rm -rfv puppet7-release-focal.deb
    apt-get update -y

    apt-get -y install puppet-agent
    echo "Provisioning phase 2 - Puppet Agent cleaning"
    systemctl stop puppet
    systemctl disable puppet
    if [ -d /etc/puppetlabs/puppet/ssl ]; then
        rm -rf /etc/puppetlabs/puppet/ssl
    fi

    if [ -f /tmp/puppet.conf ]; then
        mv /tmp/puppet.conf /etc/puppetlabs/puppet/puppet.conf
    fi
else
    echo "Provisioning phase 2 - Skipping Puppet agent"
fi
echo "Provisioning phase 2 - Done"

echo "Provisioning phase 3 - Starting: Extra packages, timezones, neofetch, firewalld, settings"
# misc
echo "Provisioning phase 3 - Timezone"
timedatectl set-timezone UTC --no-ask-password
echo "Provisioning phase 3 - Extra Packages or groups"
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install htop atop iftop iotop nmap nmon jq parted pv neofetch screen telnet ncdu multitail smartmontools zsh httpie
apt-get install -y linux-cloud-tools-virtual||true #may fail on arm64, add check for arm64
# we don't need sssd
# systemctl disable sssd.service||true
# systemctl stop sssd.service||true

# echo "Provisioning phase 3 - RK hunter"
# rkhunter --propupd

echo "Provisioning phase 3 - MOTD"

if [ -f /tmp/motd.sh ]; then
    mv /tmp/motd.sh /etc/profile.d/motd.sh
    chmod +x /etc/profile.d/motd.sh
fi

if [ "$INSTALL_HYPERV" == "true" ]; then
  echo "Provisioning phase 3 - Hyper-V/SCVMM Daemons"
  # Hyper-v daemons
   export DEBIAN_FRONTEND=noninteractive
   apt-get -y install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual
   systemctl enable hv-fcopy-daemon
   systemctl enable hv-kvp-daemon
   systemctl enable hv-vss-daemon
  if [ -e /tmp/install ]; then
    cd /tmp||exit
    chmod +x /tmp/install
    /tmp/install "$(ls /tmp/scvmm*.x64.tar)"
  fi
else
  echo "Provisioning phase 3 - Skipping Hyper-V/SCVMM Daemons"
  systemctl disable hv-fcopy-daemon || true
  systemctl disable hv-kvp-daemon || true
  systemctl disable hv-vss-daemon || true
fi

echo "Provisioning phase 3 - Firewalld"
# Firewalld basic configuration.
#apt-get install ufw -y
#ufw default allow incoming
#ufw default allow outgoing
#ufw default allow routed
#ufw allow ssh
# if [ "$INSTALL_ZABBIX" == true ]; then
#   echo "Phase 3 - firewalld - adding zabbix rules"
#   ufw allow 10050:10052/tcp
# fi

# if [ "$INSTALL_COCKPIT" == true ]; then
# echo "Phase 3 - firewalld - adding cockpit rules"
#     ufw allow 9090/tcp
# fi
# systemctl disable ufw
# ufw enable
# ufw status numbered


echo "Provisioning phase 4 - Final updates and cleaning up"

if [ "$INSTALL_UPDATES" == "true" ]; then
    echo "Provisioning phase 4 - system final updates"
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y -q upgrade
    apt-get -y -q clean all
else
    echo "Provisioning phase 4 - skipping system final updates"
fi

## Clean logs
truncate -s 0 /var/log/*.*
truncate -s 0 /var/log/**/*.*
find /var/log -type f -name '*.[0-99].gz' -exec rm {} +
# Create STAMP_FILE
if [ -e $STAMP_FILE ]; then
  rm -rf $STAMP_FILE
  touch $STAMP_FILE
fi
#neofetch || true
echo "creationDate: $(date +%Y-%m-%d_%H:%M)" >>$STAMP_FILE
echo "Provisioning phase 4 - Done"
echo "Provisioning done - all phases"