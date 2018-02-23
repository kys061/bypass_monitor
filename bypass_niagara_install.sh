#!/bin/bash
#
# Install portwell bypass driver and enable bypass
#
# Must be run as root.
#
mkdir -p /opt/stm/bypass_drivers
mkdir -p /opt/stm/bypass_drivers/niagara
cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/universal-driver-8b9_dpdk.tar.gz /opt/stm/bypass_drivers/niagara/.
cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_niagara_monitor.sh /etc/stmfiles/files/scripts/.
#
# cooper install
#
#cd  /opt/stm/bypass_drivers/portwell
#unzip caswell_drv_bypass-gen3-V1.5.1.zip
#cd src/driver
#make [KSRC=..]
#bypass_mod_installed=$(/sbin/lsmod | grep "caswell_bpgen3")
#if [ ! -z "$bypass_mod_installed" ]; then
#  rmmod caswell-bpgen3.ko
#fi
#insmod caswell-bpgen3.ko
#cd /sys/class/bypass/g3bp0
#echo 1 > func
#echo b > bypass
#echo 1 > bpe
#if [ -d /sys/class/bypass/g3bp1 ];
#then
#  cd /sys/class/bypass/g3bp1
#  echo 1 > func
#  echo b > bypass
#  echo 1 > bpe
#fi

#
# fiber install
#
is_fiber=$(lspci -m |grep Ether |grep QLogic -o)
if [ ! -z "$is_fiber" ]; then
  cd  /opt/stm/bypass_drivers/niagara
  tar -zxvf universal-driver-8b9_dpdk.tar.gz
  cd universal-driver-8b9_dpdk/
  make
  make install
  bypass_mod_installed=$(/sbin/lsmod | grep "niagara")
  if [ ! -z "$bypass_mod_installed" ]; then
    rmmod niagara
  fi
#  i2c_mod_installed=$(/sbin/lsmod |grep "i2c_i801")
#  if [ -z "$i2c_mod_installed" ]; then
#    modprobe i2c-i801
#  fi
  make insmod
  ## mode enable d2 mode -> active : bypass
  sudo niagara_util -d2
  ## hb enable
  #sudo niagara_util -a 0
  ## hb disable
  sudo niagara_util -r
  ## LLCF enable
  sudo niagara_util -Q

  sed -i '14a\\sudo niagara_util -Q' /etc/rc.local
  sed -i '14a\\## LLCF enable' /etc/rc.local
  sed -i '14a\\sudo niagara_util -r' /etc/rc.local
  sed -i '14a\\## hb disable' /etc/rc.local
  sed -i '14a\\sudo niagara_util -d2' /etc/rc.local
  sed -i '14a\\## mode enable d2 mode -> active : bypass' /etc/rc.local
  sed -i '14a\\sudo insmod /opt/stm/bypass_drivers/niagara/universal-driver-8b9_dpdk/module/niagara.ko' /etc/rc.local
  sed -i '14a\\## module enable' /etc/rc.local

  if [ ! -e /etc/init.d/bypass_niagara_enable.sh ]; then
	  cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_niagara_enable.sh /etc/init.d/.
	if [ ! -e /etc/rc6.d/K20bypass_niagara_enable.sh ]; then
	    # for reboot
		cd /etc/rc6.d
		ln -s ../init.d/bypass_niagara_enable.sh K20bypass_niagara_enable.sh
		echo "make link file in rc6.d"
	fi
	if [ ! -e /etc/rc0.d/K20bypass_niagara_enable.sh ]; then
		# for shutdown
		cd /etc/rc0.d
		ln -s ../init.d/bypass_niagara_enable.sh K20bypass_niagara_enable.sh
		echo "make link file in rc0.d"
	fi
  fi
fi
