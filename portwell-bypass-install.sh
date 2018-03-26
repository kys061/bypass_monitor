#!/bin/bash
#
# Install portwell bypass driver and enable bypass
#
# Must be run as root.
#
mkdir -p /opt/stm/bypass_drivers
mkdir -p /opt/stm/bypass_drivers/portwell
mkdir -p /opt/stm/bypass_drivers/portwell_fiber
cp /opt/stm/target/caswell_drv_network-bypass-V3.20.0.zip /opt/stm/bypass_drivers/portwell_fiber/.
cp /opt/stm/target/portwell-bypass-monitor.sh /opt/stm/bypass_drivers/portwell_fiber/.
cp /opt/stm/target/caswell_drv_bypass-gen3-V1.5.1.zip /opt/stm/bypass_drivers/portwell/.
cp /opt/stm/target/portwell-bypass-monitor.sh /opt/stm/bypass_drivers/portwell/.
#
# cooper install
#
cd  /opt/stm/bypass_drivers/portwell
unzip caswell_drv_bypass-gen3-V1.5.1.zip
cd src/driver
make [KSRC=..]
bypass_mod_installed=$(/sbin/lsmod | grep "caswell_bpgen3")
if [ ! -z "$bypass_mod_installed" ]; then
  rmmod caswell-bpgen3.ko
fi
insmod caswell-bpgen3.ko
cd /sys/class/bypass/g3bp0
echo 1 > func
echo b > bypass
echo 1 > bpe
if [ -d /sys/class/bypass/g3bp1 ];
then
  cd /sys/class/bypass/g3bp1
  echo 1 > func
  echo b > bypass
  echo 1 > bpe
fi
#
# fiber install
#
is_fiber=$(lspci |grep Ether |grep Fiber -o)
if [ ! -z "$is_fiber" ]; then
  cd  /opt/stm/bypass_drivers/portwell_fiber
  unzip caswell_drv_network-bypass-V3.20.0.zip
  cd driver
  make [KSRC=..]
  bypass_mod_installed=$(/sbin/lsmod | grep "network_bypass")
  if [ ! -z "$bypass_mod_installed" ]; then
    rmmod network_bypass
  fi
  i2c_mod_installed=$(/sbin/lsmod |grep "i2c_i801")
  if [ -z "$i2c_mod_installed" ]; then
    modprobe i2c-i801
  fi

  insmod network-bypass.ko board=CAR3040
  cd /sys/class/misc/caswell_bpgen2/slot0/
  echo 2 > bypass0
  echo 1 > bpe0
  if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass1 ];
  then
    cd /sys/class/misc/caswell_bpgen2/slot0/
    echo 2 > bypass1
    echo 1 > bpe1
  fi
  if [ ! -e /etc/init.d/bypass_portwell_enable.sh ]; then
    cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_portwell_enable.sh /etc/init.d/.
	if [ ! -e /etc/rc6.d/K20bypass_portwell_enable.sh ]; then
	  # for reboot
          cd /etc/rc6.d
          ln -s ../init.d/bypass_portwell_enable.sh K20bypass_portwell_enable.sh
          echo "make link file in rc6.d"
	fi
	if [ ! -e /etc/rc0.d/K20bypass_portwell_enable.sh ]; then
          # for shutdown
          cd /etc/rc0.d
          ln -s ../init.d/bypass_portwell_enable.sh K20bypass_portwell_enable.sh
          echo "make link file in rc0.d"
	fi
  fi
fi
