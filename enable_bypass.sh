#!/bin/bash
bypass_masters=/etc/stm/bypass_masters
id=admin
pass=admin
version=$(echo 'show version' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |awk '{print $1}' |egrep 'V[0-9]+\.[0-9]+' -o)

#
# get real port (stmx)
#
function get_real_ports
{
	if [ $version == "V7.1" ]; then
		realint_count=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |wc -l)
	else
		realint_count=$(echo 'show interfaces select interface system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $10}' |wc -l)
	fi
	for ((i=0; i<$realint_count; i++));
	do
		if [ $i == 0  ]; then
			if [ $version == "V7.1" ]; then
				virt_port_1_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 1 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
			else
				virt_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 1 {print}')
			fi
			if [[ $virt_port_1_index == '' ]]; then
				virt_port_1=''
				real_port_1=''
			else
				if [ $version == "V7.1" ]; then
					virt_port_1=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_1_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_1=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_1 | cut -d "," -f2)
				else
					#virt_port_1=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_1_index |awk '{print $1}')
					virt_port_1=$(cat /etc/stm/system_virt_real_device.csv |grep virt -v |cut -d',' -f1 |awk 'FNR == 1 {print}')
					real_port_1=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_1 | cut -d "," -f2)
				fi
			fi
		elif [ $i == 1 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_2_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 2 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
			else
				virt_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 2 {print}')
			fi
			if [[ $virt_port_2_index == '' ]]; then
				virt_port_2=''
				real_port_2=''
			else
				if [ $version == "V7.1" ]; then
					virt_port_2=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_2_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_2=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_2 | cut -d "," -f2)
				else
					#virt_port_2=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_2_index |awk '{print $1}')
					virt_port_2=$(cat /etc/stm/system_virt_real_device.csv |grep virt -v |cut -d',' -f1 |awk 'FNR == 2 {print}')
					real_port_2=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_2 | cut -d "," -f2)
				fi
			fi
		elif [ $i == 2 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_3_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 3 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
			else
				virt_port_3_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 3 {print}')
			fi
			if [[ $virt_port_3_index == '' ]]; then
				virt_port_3=$virt_port_1
				real_port_3=$real_port_1
			else
				if [ $version == "V7.1" ]; then
					virt_port_3=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_3_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_3=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_3 | cut -d "," -f2)
				else
					#virt_port_3=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_3_index |awk '{print $1}')
					virt_port_3=$(cat /etc/stm/system_virt_real_device.csv |grep virt -v |cut -d',' -f1 |awk 'FNR == 3 {print}')
					real_port_3=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_3 | cut -d "," -f2)
				fi
			fi
		elif [ $i == 3 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_4_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 4 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
			else
				virt_port_4_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 4 {print}')
			fi
			if [[ $virt_port_4_index == '' ]]; then
				virt_port_4=$virt_port_2
				real_port_4=$real_port_2
			else
				if [ $version == "V7.1" ]; then
					virt_port_4=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_4_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_4=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_4 | cut -d "," -f2)
				else
					#virt_port_4=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_4_index |awk '{print $1}')
					virt_port_4=$(cat /etc/stm/system_virt_real_device.csv |grep virt -v |cut -d',' -f1 |awk 'FNR == 4 {print}')
					real_port_4=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_4 | cut -d "," -f2)
				fi
			fi
		fi
	done
}

#
# check bump's interface type (cooper or fiber)
#
function check_bump_type
{
	# check bump type
	if [ $version == "V7.1" ]; then
		real_port_1_pci=$(cat /etc/stm/system_devices.csv |grep "$real_port_1\$" |awk -F"," '{print $2}' |cut -d":" -f2,3)
		real_port_3_pci=$(cat /etc/stm/system_devices.csv |grep "$real_port_3\$" |awk -F"," '{print $2}' |cut -d":" -f2,3)
	else
		real_port_1_pci=$(cat /etc/stm/devices.csv |grep "$real_port_1" |awk -F"," '{print $3}' |cut -d"\"" -f2 |cut -d":" -f2,3)
		real_port_2_pci=$(cat /etc/stm/devices.csv |grep "$real_port_2" |awk -F"," '{print $3}' |cut -d"\"" -f2 |cut -d":" -f2,3)
	fi

	bump_type=$(lspci |grep "$real_port_1_pci" |grep Fiber -o)
	bump2_type=$(lspci |grep "$real_port_3_pci" |grep Fiber -o)
	if [ ! -z $bump_type ]; then
		bump_type="fiber"
	else
		bump_type="cooper"
	fi
	if [ ! -z $bump2_type ]; then
		bump2_type="fiber"
	else
		bump2_type="cooper"
	fi
}

# main logic
# 1. get pid of bypass script and get real ports(stmx) and check bump's type
# 2. case each bump's type cooper, go to cooper bypass module and change it bypass mode
# 3. case each bump's type fiber, go to fiber bypass module and change it bypass mode
portwell_bypass_pid=$(ps ax | grep portwell-bypass-monitor.sh | head -n 1 | cut -d" " -f2)
get_real_ports
check_bump_type
if [ "$bump_type" == "cooper" ] || [ "$bump2_type" == "cooper" ]; then
  if [ -d /opt/stm/bypass_drivers/portwell ];
  then
    if [ ! -z $portwell_bypass_pid ] && [ "$1" == "FORCE" ]; then
      killall -9 portwell-bypass-monitor.sh >>/var/log/stm_stop.log 2>&1
    fi
    if [ -d /sys/class/bypass/g3bp0 ] && [ "$1" == "bump1" ] || [ "$1" == "FORCE" ]; then
      cd /sys/class/bypass/g3bp0
      bump1_bypass_status=$(cat bypass)
      if [ "$bump1_bypass_status" != "b" ]; then
        echo $(date -Iseconds) "Enabling bypass on bump1" >> /var/log/stm_stop.log
        echo "Enabling bypass on bump1"
        echo b > bypass
        echo 1 > nextboot
      fi
    fi
    if [ -d /sys/class/bypass/g3bp1 ] && [ "$1" == "bump2" ] || [ "$1" == "FORCE" ]; then
      cd /sys/class/bypass/g3bp1
      bump2_bypass_status=$(cat bypass)
      if [ "$bump2_bypass_status" != "b" ]; then
        echo $(date -Iseconds) "Enabling bypass on bump2" >> /var/log/stm_stop.log
        echo "Enabling bypass on bump2"
        echo b > bypass
        echo 1 > nextboot
      fi
    fi
  fi
else
  if [ -d /opt/stm/bypass_drivers/portwell_fiber ];
  then
    if [ ! -z $portwell_bypass_pid ]; then
      killall -9 portwell-bypass-monitor.sh >>/var/log/stm_stop.log 2>&1
    fi
    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass0 ] && [ "$1" == "bump1" ] || [ "$1"=="FORCE" ]; then
      cd /sys/class/misc/caswell_bpgen2/slot0/
      bump1_bypass_fiber_status=$(cat bypass0)
      if [ "$bump1_bypass_fiber_status" != "2" ]; then
        echo $(date -Iseconds) "Enabling bypass on bump1" >> /var/log/stm_stop.log
        echo "Enabling bypass on bump1"
        echo 2 > bypass0
        echo 1 > nextboot0
      fi
    fi
    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass1 ] && [ "$1" == "bump2" ] || [ "$1"=="FORCE" ]; then
      cd /sys/class/misc/caswell_bpgen2/slot0/
      bump2_bypass_fiber_status=$(cat bypass1)
      if [ "$bump2_bypass_fiber_status" != "2" ]; then
        echo $(date -Iseconds) "Enabling bypass on bump2" >> /var/log/stm_stop.log
        echo "Enabling bypass on bump2"
        echo 2 > bypass1
        echo 1 > nextboot1
      fi
    fi
  fi
fi

# here is for silicom_bypass and not consider for portwell.
silicom_bypass_pid=$(ps ax | grep silicom-bypass-monitor.sh | head -n 1 | cut -d" " -f1)
if [ ! -z silicom_bypass_pid ]; then
  if [ -d /opt/stm/bypass_drivers/silicom ]; then
    killall -9 silicom-bypass-monitor.sh >>/var/log/stm_stop.log 2>&1
    echo $(date -Iseconds) "Disabling silicom bypass segments" >> /var/log/stm_stop.log
    echo "Disabling silicom bypass segments"
    for bypass_master in `cat $bypass_masters`
    do
      echo $(date -Iseconds) "$bypass_master read from $bypass_masters" >> /var/log/stm_stop.log
      echo "$bypass_master read from $bypass_masters"
      master_pci_coord=$(cat /etc/stm/system_devices.csv | grep $bypass_master | cut -d":" -f2,3 | cut -d"," -f1)
      echo $master_pci_coord
      bypass_status=$(/opt/stm/bypass_drivers/silicom/bp_ctl-5.0.65.1/bpctl_util $master_pci_coord get_bypass | cut -d" " -f6)
      echo $(date -Iseconds) "$bypass_status" >> /var/log/stm_stop.log
      echo $bypass_status
      echo $(date -Iseconds) "Enabling bypass on bump1" >> /var/log/stm_stop.log
      echo "Enabling bypass on bump1"
      /opt/stm/bypass_drivers/silicom/bp_ctl-5.0.65.1/bpctl_util $master_pci_coord set_std_nic off >> /var/log/stm_stop.log 2>&1
      /opt/stm/bypass_drivers/silicom/bp_ctl-5.0.65.1/bpctl_util $master_pci_coord set_bypass on >> /var/log/stm_stop.log 2>&1
    done
  fi
fi
