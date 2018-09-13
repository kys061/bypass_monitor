#!/bin/bash
#
# Install portwell bypass driver and enable bypass
#
# Must be run as root.
#
kernel_ver=4.15.0-20-generic
uname_r=$(uname -r)

if [ "$uname_r" = "$kernel_ver" ]; then
	version=bp_ctl-5.2.0.37
else
	version=bp_ctl-5.0.65.1
fi

mkdir -p /opt/stm/bypass_drivers
mkdir -p /opt/stm/bypass_drivers/silicom_bpdrv
cp /opt/stm/target/$version.tar.gz /opt/stm/bypass_drivers/silicom_bpdrv/.
if [ -e /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_monitor.sh ]; then
	cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_monitor.sh /etc/stmfiles/files/scripts/.
else
  cp /home/saisei/bypass_silicom_monitor.sh /etc/stmfiles/files/scripts/.
fi
#
# install silicom bpdrv
#
is_silicom=$(lspci -m |grep Ether |grep Silicom -o)
if [ -d /opt/stm/bypass_drivers/silicom_bpdrv/$version ]; then
	if [ "$uname_r" = "$kernel_ver" ]; then
		cp /etc/stmfiles/files/scripts/silicom_multi.service /lib/systemd/system/.
		cd /lib/systemd/system/
		systemctl daemon-reload
		systemctl enable silicom_multi.service
	else
		echo "$version silicom bypass drv is already installed!"
		if [ ! -e /etc/init.d/bypass_silicom_enable.sh ]; then
			# cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_enable.sh /etc/init.d/.
			if [ -e /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_enable.sh ]; then
				cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_enable.sh /etc/init.d/.
			else
				cp /etc/stmfiles/files/scripts/bypass_silicom_enable.sh /etc/init.d/.
			fi		
			if [ ! -e /etc/rc6.d/K20bypass_silicom_enable.sh ]; then
					# for reboot
				cd /etc/rc6.d
				ln -s ../init.d/bypass_silicom_enable.sh K20bypass_silicom_enable.sh
				echo "make link file in rc6.d"
			fi
			if [ ! -e /etc/rc0.d/K20bypass_silicom_enable.sh ]; then
				# for shutdown
				cd /etc/rc0.d
				ln -s ../init.d/bypass_silicom_enable.sh K20bypass_silicom_enable.sh
				echo "make link file in rc0.d"
			fi
		fi
	fi
else
  if [ ! -z "$is_silicom" ]; then
		cd  /opt/stm/bypass_drivers/silicom_bpdrv
		tar -zxvf $version.tar.gz
		cd $version
		make
		make install
		bpctl_start
		
		if [ "$uname_r" = "$kernel_ver" ]; then
			cp /etc/stmfiles/files/scripts/silicom_multi.service /lib/systemd/system/.
			cd /lib/systemd/system/
			systemctl daemon-reload
			systemctl enable silicom_multi.service
		else
			if [ ! -e /etc/init.d/bypass_silicom_enable.sh ]; then
				# cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_enable.sh /etc/init.d/.
				if [ -e /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_enable.sh ]; then
					cp /home/saisei/deploy/script/bypass7_2/bypass_monitor/bypass_silicom_enable.sh /etc/init.d/.
				else
					cp /etc/stmfiles/files/scripts/bypass_silicom_enable.sh /etc/init.d/.
				fi
				if [ ! -e /etc/rc6.d/K20bypass_silicom_enable.sh ]; then
					# for reboot
					cd /etc/rc6.d
					ln -s ../init.d/bypass_silicom_enable.sh K20bypass_silicom_enable.sh
					echo "make link file in rc6.d"
				fi
				if [ ! -e /etc/rc0.d/K20bypass_silicom_enable.sh ]; then
					# for shutdown
					cd /etc/rc0.d
					ln -s ../init.d/bypass_silicom_enable.sh K20bypass_silicom_enable.sh
					echo "make link file in rc0.d"
				fi
			fi
		fi
	fi
fi

