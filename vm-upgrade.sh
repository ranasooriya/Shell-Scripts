#!/bin/bash

# Authors:
# * Ishanka Ranasooriya
# * v1
#
# Description: Install or Upgrade VM tools

OS=$(lsb_release -a 2>/dev/null | grep 'Distributor ID' | cut -d: -f2 | sed 's/^[ \t]*//')
VMTOOL=$(whereis vmtoolsd |cut -d: -f2 | sed 's/^[ \t]*//')

installVMTools () {
    cd /tmp
    wget -c http://10.25.5.80/repos/vmwaretools/VMwareTools-10.3.25-20206839.tar.gz
    tar -zxvf /tmp/VMwareTools-10.3.25-20206839.tar.gz
    cd /tmp/vmware-tools-distrib/
    ./vmware-install.pl -d default
}

if [[ $OS == "Ubuntu" ]]; then
    if ! command -v bc &> /dev/null; then
        apt-get update && apt-get install bc -y
    fi

    openvm_tools_version=$(dpkg -l | grep 'open-vm-tools' | awk '{print $3}' | cut -d: -f2 | cut -d- -f1)

    if [[ -z $openvm_tools_version ]]; then
        installVMTools
        vmware_tools_version=$($VMTOOL -v | cut -d, -f2 | sed 's/^[ \t]*//' | cut -d\( -f1)
        echo "VM Tool Upgraded to version $vmware_tools_version"
    else
        apt-get update && apt-get upgrade open-vm-tools -y
        openvm_tools_version=$(dpkg -l | grep 'open-vm-tools' | awk '{print $3}' | cut -d: -f2 | cut -d- -f1)
        echo "Open VM Tool Upgraded to version $openvm_tools_version"
    fi
else
    if ! command -v bc &> /dev/null; then
         yum install bc -y
    fi

    openvm_tools_version=$(rpm -qa | grep 'open-vm-tools-[0-9.]*-[0-9]*' | cut -d '-' -f4)

    if [[ -z $openvm_tools_version ]]; then
        installVMTools
        vmware_tools_version=$($VMTOOL -v | cut -d, -f2 | sed 's/^[ \t]*//' | cut -d\( -f1)
        echo "VM Tool Upgraded to version $vmware_tools_version"
    else
        yum upgrade open-vm-tools -y
        openvm_tools_version=$(rpm -qa | grep 'open-vm-tools-[0-9.]*-[0-9]*' | cut -d '-' -f4)
        echo "Open VM Tool Upgraded to version $openvm_tools_version"
    fi
fi