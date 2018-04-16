#!/bin/bash
#
#####################################
# Copyright (c) 2018 Saisei         #
# Last Date : 2018.02.20            #
# Writer : yskang(kys061@gmail.com) #
#####################################
#
# Install portwell bypass driver and enable bypass
#
# Must be run as root.
#
bump1_operstatus="down"
bump2_operstatus="down"
stm_operstatus="down"
em1_adminstatus="down"
p1p1_adminstatus="down"
eth0_adminstatus="down"
eth1_adminstatus="down"
eth2_adminstatus="down"
eth3_adminstatus="down"
eth4_adminstatus="down"
eth5_adminstatus="down"
dumping_core="false"

bump_type="cooper"
model_type="small"
stm_status="false"
id="admin"
pass="admin"
sleep 10
# check stm and make system_virt_real_device.csv until stm is up
# virt : the name that user want to make
# real : the name that stm makes
# must be interface ordered in /etc/stm/system_virt_real_device.csv : seg1-ext,int, seg2-ext,int
while ! $stm_status; do
	if echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | egrep '(Socket|Ethernet)' >/dev/null 2>&1; then
		version=$(echo 'show version' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | awk '{print $1}' | egrep 'V[0-9]+\.[0-9]+' -o)
		model_type=$(echo 'show parameter model' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | awk '{print $3}')
		if [ $version == "V7.1" ]; then
			if [ $model_type == "tiny" ]; then
				bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | wc -l)
			else
				bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | wc -l)
			fi
			stm_status='true'
			echo 'virt,real' >/etc/stm/system_virt_real_device.csv
			model_type=$(echo 'show parameter model' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost | cut -d"=" -f2 | sed -e 's/^[[:space:]]*//')
			if [ $model_type == "tiny" ]; then
				echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | awk '{print $1 "," $11; fflush()}' >>/etc/stm/system_virt_real_device.csv
			else
				echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $1 "," $11; fflush()}' >>/etc/stm/system_virt_real_device.csv
			fi
			if [ ! -e /etc/stm/system_virt_real_device.csv ]; then
				echo 'virt,real' >/etc/stm/system_virt_real_device.csv
				if [ $model_type == "tiny" ]; then
					echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | awk '{print $1 "," $11; fflush()}' >>/etc/stm/system_virt_real_device.csv
				else
					echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $1 "," $11; fflush()}' >>/etc/stm/system_virt_real_device.csv
				fi
				if [ $? -eq 1 ]; then
					sleep 10
					echo 'virt,real' >/etc/stm/system_virt_real_device.csv
					if [ $model_type == "tiny" ]; then
						echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | awk '{print $1 "," $11; fflush()}' >>/etc/stm/system_virt_real_device.csv
					else
						echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $1 "," $11; fflush()}' >>/etc/stm/system_virt_real_device.csv
					fi
				fi
			fi
		else
			if [ $model_type == "tiny" ]; then
				bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | wc -l)
			else
				bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | wc -l)
			fi
			stm_status='true'
			echo 'virt,real' >/etc/stm/system_virt_real_device.csv
			if [ $bump_count == 4 ]; then
				if [ $model_type == "tiny" ]; then
					soc_a=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $10}' | awk 'FNR == 1 {print}' | rev | cut -d":" -f2)
					soc_b=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $10}' | awk 'FNR == 2 {print}' | rev | cut -d":" -f2)
					soc_c=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $10}' | awk 'FNR == 1 {print}' | rev | cut -d":" -f2)
					soc_d=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $10}' | awk 'FNR == 2 {print}' | rev | cut -d":" -f2)
					# compare pci value of interface
					if [ $soc_a -lt $soc_b ]; then
						echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
						if [ $soc_c -lt $soc_d ]; then
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
						else
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
						fi
					else
						echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
						# compare pci value of interface
						if [ $soc_c -lt $soc_d ]; then
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
						else
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
						fi
					fi
				else
					eth_a=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $10}' | awk 'FNR == 1 {print}' | rev | cut -d":" -f2) # 20
					eth_b=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $10}' | awk 'FNR == 2 {print}' | rev | cut -d":" -f2) # 40
					eth_c=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $10}' | awk 'FNR == 1 {print}' | rev | cut -d":" -f2) # 30
					eth_d=$(echo 'show interfaces select pci_address' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $10}' | awk 'FNR == 2 {print}' | rev | cut -d":" -f2) # 50
					# compare pci value of interface
					if [ $eth_a -lt $eth_b ]; then
						echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
						if [ $eth_c -lt $eth_d ]; then
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
						else
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
						fi
					else
						echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
						# compare pci value of interface
						if [ $eth_c -lt $eth_d ]; then
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
						else
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 2 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
							echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
						fi
					fi
				fi
			else
				if [ $model_type == "tiny" ]; then
					echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
					echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
				else
					echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep External | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
					echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep Internal | awk '{print $1 "," $10; fflush()}' | awk 'FNR == 1 {print}' >>/etc/stm/system_virt_real_device.csv
				fi
			fi
		fi
	fi
	echo "stm setup is not enabled or not running.." | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	sleep 3
done

#
# get real port (stmx)
#
function get_real_ports() {
	if [ $version == "V7.1" ]; then
		realint_count=$(snmpwalk -v 2c -c public localhost ifIndex | egrep 'INTEGER: [0-9]$' | wc -l)
	else
		realint_count=$(echo 'show interfaces select interface system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | wc -l)
	fi
	for ((i = 0; i < $realint_count; i++)); do
		if [ $i == 0 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_1_index=$(snmpwalk -v 2c -c public localhost ifIndex | egrep 'INTEGER: [0-9]$' | awk 'FNR == 1 {print}' | cut -d " " -f1 | rev | cut -d "." -f1)
			else
				virt_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 1 {print}')
			fi
			if [[ $virt_port_1_index == '' ]]; then
				virt_port_1=''
				real_port_1=''
			else
				if [ $version == "V7.1" ]; then
					virt_port_1=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 ifName.$virt_port_1_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_1=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_1 | cut -d "," -f2)
				else
					#virt_port_1=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_1_index |awk '{print $1}')
					virt_port_1=$(cat /etc/stm/system_virt_real_device.csv | grep virt -v | cut -d',' -f1 | awk 'FNR == 1 {print}')
					real_port_1=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_1 | cut -d "," -f2)
				fi
			fi
		elif [ $i == 1 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_2_index=$(snmpwalk -v 2c -c public localhost ifIndex | egrep 'INTEGER: [0-9]$' | awk 'FNR == 2 {print}' | cut -d " " -f1 | rev | cut -d "." -f1)
			else
				virt_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 2 {print}')
			fi
			if [[ $virt_port_2_index == '' ]]; then
				virt_port_2=''
				real_port_2=''
			else
				if [ $version == "V7.1" ]; then
					virt_port_2=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 ifName.$virt_port_2_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_2=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_2 | cut -d "," -f2)
				else
					#virt_port_2=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_2_index |awk '{print $1}')
					virt_port_2=$(cat /etc/stm/system_virt_real_device.csv | grep virt -v | cut -d',' -f1 | awk 'FNR == 2 {print}')
					real_port_2=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_2 | cut -d "," -f2)
				fi
			fi
		elif [ $i == 2 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_3_index=$(snmpwalk -v 2c -c public localhost ifIndex | egrep 'INTEGER: [0-9]$' | awk 'FNR == 3 {print}' | cut -d " " -f1 | rev | cut -d "." -f1)
			else
				virt_port_3_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 3 {print}')
			fi
			if [[ $virt_port_3_index == '' ]]; then
				virt_port_3=$virt_port_1
				real_port_3=$real_port_1
			else
				if [ $version == "V7.1" ]; then
					virt_port_3=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 ifName.$virt_port_3_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_3=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_3 | cut -d "," -f2)
				else
					#virt_port_3=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_3_index |awk '{print $1}')
					virt_port_3=$(cat /etc/stm/system_virt_real_device.csv | grep virt -v | cut -d',' -f1 | awk 'FNR == 3 {print}')
					real_port_3=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_3 | cut -d "," -f2)
				fi
			fi
		elif [ $i == 3 ]; then
			if [ $version == "V7.1" ]; then
				virt_port_4_index=$(snmpwalk -v 2c -c public localhost ifIndex | egrep 'INTEGER: [0-9]$' | awk 'FNR == 4 {print}' | cut -d " " -f1 | rev | cut -d "." -f1)
			else
				virt_port_4_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 4 {print}')
			fi
			if [[ $virt_port_4_index == '' ]]; then
				virt_port_4=$virt_port_2
				real_port_4=$real_port_2
			else
				if [ $version == "V7.1" ]; then
					virt_port_4=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 ifName.$virt_port_4_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
					real_port_4=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_4 | cut -d "," -f2)
				else
					#virt_port_4=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_4_index |awk '{print $1}')
					virt_port_4=$(cat /etc/stm/system_virt_real_device.csv | grep virt -v | cut -d',' -f1 | awk 'FNR == 4 {print}')
					real_port_4=$(cat /etc/stm/system_virt_real_device.csv | grep $virt_port_4 | cut -d "," -f2)
				fi
			fi
		fi
	done
}

#
# check bump's interface type (cooper or fiber)
#
function check_bump_type() {
	# check bump type
	if [ $version == "V7.1" ]; then
		real_port_1_pci=$(cat /etc/stm/system_devices.csv | grep "$real_port_1\$" | awk -F"," '{print $2}' | cut -d":" -f2,3)
		if [ $realint_count == "4" ]; then
			real_port_3_pci=$(cat /etc/stm/system_devices.csv | grep "$real_port_3\$" | awk -F"," '{print $2}' | cut -d":" -f2,3)
		fi
	else
		real_port_1_pci=$(cat /etc/stm/devices.csv | grep "$real_port_1" | awk -F"," '{print $3}' | cut -d"\"" -f2 | cut -d":" -f2,3)
		if [ $realint_count == "4" ]; then
			real_port_3_pci=$(cat /etc/stm/devices.csv | grep "$real_port_3" | awk -F"," '{print $3}' | cut -d"\"" -f2 | cut -d":" -f2,3)
		fi
	fi

	bump_type=$(lspci | grep "$real_port_1_pci" | grep SFP+ -o)
	bump2_type=$(lspci | grep "$real_port_3_pci" | grep SFP+ -o)
	int_type=$(lspci -m | grep "$real_port_1_pci" | grep QLogic -o)
	if [ ! -z $bump_type ]; then
		bump_type="fiber"
	else
		bump_type="cooper"
	fi

	if [ "$realint_count" == "4" ]; then
		if [ ! -z $bump2_type ]; then
			bump2_type="fiber"
		else
			bump2_type="cooper"
		fi
	else
		bump2_type="None"
	fi
}
#
# check interface is enabled
#
function check_model_type_enabled() {
	if [ $version == "V7.1" ]; then
		if [ $model_type == "tiny" ]; then
			if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
				bitw_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_1 | awk '{print $4}')
			fi
			if [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
				bitw_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_2 | awk '{print $4}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
				bitw2_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_3 | awk '{print $4}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
				bitw2_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_4 | awk '{print $4}')
			fi
		else
			if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
				bitw_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_1 | awk '{print $4}')
			fi
			if [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
				bitw_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_2 | awk '{print $4}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
				bitw2_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_3 | awk '{print $4}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
				bitw2_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_4 | awk '{print $4}')
			fi
			#       declare "bitw${2}_port_${1}_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_1 |awk '{print $4}')"
		fi
	else
		if [ $model_type == "tiny" ]; then
			#       declare "bitw${2}_port_${1}_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |grep $real_port_1 |awk '{print $4}')"
			if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
				bitw_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_1 | awk '{print $6}')
			fi
			if [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
				bitw_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_2 | awk '{print $6}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
				bitw2_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_3 | awk '{print $6}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
				bitw2_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Socket | grep $real_port_4 | awk '{print $6}')
			fi
		else
			if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
				bitw_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_1 | awk '{print $6}')
			fi
			if [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
				bitw_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_2 | awk '{print $6}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
				bitw2_port_1_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_3 | awk '{print $6}')
			fi
			if [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
				bitw2_port_2_enable=$(echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | grep $real_port_4 | awk '{print $6}')
			fi
			#       declare "bitw${2}_port_${1}_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_1 |awk '{print $4}')"
		fi
	fi
}

#
# check bump's status (default:two)
#
function check_bumps() {
	bitw_port_1=$virt_port_1
	bitw_port_2=$virt_port_2
	port3=$virt_port_3
	port4=$virt_port_4
	#       bitw_port_1=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
	#       bitw_port_2=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 2 -v "." | tail -n 1)
	#       port3=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 3 -v "." | tail -n 1)
	#       port4=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 4 -v "." | tail -n 1)
	# check if each port is diff or not
	if [ ! -z $port3 ] && [ ! -z $port4 ] && [ "$port3" != "$bitw_port_1" ] && [ "$port3" != "$bitw_port_2" ] && [ "$port4" != "$bitw_port_1" ] && [ "$port4" != "$bitw_port_2" ]; then
		bitw2_port_1=$port3
		bitw2_port_2=$port4
		seg_count=2
	else
		seg_count=1
	fi
	# get bump1's port1 adminstatus and enabled.
	if [ ! -z $bitw_port_1 ]; then
		if [ "$bitw_port_1" != "tree)" ]; then
			if [ $version == "V7.1" ]; then
				bitw_port_1_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw_port_1 | cut -d " " -f1 | rev | cut -d "." -f1)
				bitw_port_1_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_1_index | cut -d" " -f4 | awk -F"(" '{print $1}')
				#               bitw_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_1 |awk '{print $4}')
				check_model_type_enabled 1 1
				bitw_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
				#               bitw_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
			else
				bitw_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 1 {print}')
				# echo "bitw_port_1_adminstatus BEFORE: ""$bitw_port_1_adminstatus"
				bitw_port_1_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep $bitw_port_1_index | awk '{print $13}')
				bitw_port_1_adminstatus=$(echo "$bitw_port_1_adminstatus" | awk '{print tolower($0)}')
				# echo "bitw_port_1_adminstatus after: ""$bitw_port_1_adminstatus"
				check_model_type_enabled 1 1
			fi
		fi
	fi
	if [ ! -z $bitw_port_1_adminstatus ]; then
		# get bump1's port2 adminstatus and enabled.
		if [ ! -z $bitw_port_2 ]; then
			if [ $version == "V7.1" ]; then
				bitw_port_2_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw_port_2 | cut -d " " -f1 | rev | cut -d "." -f1)
				bitw_port_2_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_2_index | cut -d " " -f4 | awk -F"(" '{print $1}')
				#               bitw_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_2 |awk '{print $4}')
				check_model_type_enabled 1 2
				bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
				#               bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
			else
				bitw_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 2 {print}')
				bitw_port_2_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep $bitw_port_2_index | awk '{print $13}')
				bitw_port_2_adminstatus=$(echo "$bitw_port_2_adminstatus" | awk '{print tolower($0)}')
				check_model_type_enabled 1 2
			fi
		fi
	fi
	# get bump2's port1 adminstatus and enabled.
	if [ ! -z $bitw2_port_1 ]; then
		if [ "$bitw_port_1" != "tree)" ]; then
			if [ $version == "V7.1" ]; then
				bitw2_port_1_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw2_port_1 | cut -d " " -f1 | rev | cut -d "." -f1)
				bitw2_port_1_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw2_port_1_index | cut -d" " -f4 | awk -F"(" '{print $1}')
				#               bitw2_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_3 |awk '{print $4}')
				check_model_type_enabled 2 1
				bitw2_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_3 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
				#               bitw2_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw2_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
			else
				bitw2_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 3 {print}')
				bitw2_port_1_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep $bitw2_port_1_index | awk '{print $13}')
				bitw2_port_1_adminstatus=$(echo "$bitw2_port_1_adminstatus" | awk '{print tolower($0)}')
				check_model_type_enabled 2 1
			fi
		fi
	fi
	if [ ! -z $bitw2_port_1_adminstatus ]; then
		# get  bump2's port2 adminstatus and enabled
		if [ ! -z $bitw2_port_2 ]; then
			if [ $version == "V7.1" ]; then
				bitw2_port_2_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw2_port_2 | cut -d " " -f1 | rev | cut -d "." -f1)
				bitw2_port_2_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw2_port_2_index | cut -d " " -f4 | awk -F"(" '{print $1}')
				#               bitw2_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_4 |awk '{print $4}')
				check_model_type_enabled 2 2
				bitw2_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_4 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
				#               bitw2_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
			else
				bitw2_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep Ethernet | awk '{print $10}' | awk 'FNR == 4 {print}')
				bitw2_port_2_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost | grep $bitw2_port_2_index | awk '{print $13}')
				bitw2_port_2_adminstatus=$(echo "$bitw2_port_2_adminstatus" | awk '{print tolower($0)}')
				check_model_type_enabled 2 2
			fi
		fi
	fi
	# 1. check if each bump's ports is up and enabled or not,
	# 2. if bump's ports are not up or enabled, let status DOWN,
	# 3. if bump's ports are up and enabled, not thread hang of interface, let status UP
	if [ ! -z $bitw_port_2_adminstatus ]; then
		if [ "$bitw_port_1_adminstatus" == "up" ]; then
			if [ "$bitw_port_2_adminstatus" == "up" ]; then
				if [ "$bump_type" == "cooper" ]; then
					if [ -d /sys/class/bypass/g3bp0 ]; then
						if [ $bitw_port_1_enable == "Enabled" ] && [ $bitw_port_2_enable == "Enabled" ]; then
							if [ $model_type == "tiny" ]; then
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									ps -elL | grep $virt_port_2 >/dev/null 2>&1
									if [ $? -eq 0 ]; then
										bump1_operstatus="up"
									fi
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							else
								# check interface thread hang
								ps -elL | grep $virt_port_1 >/dev/null 2>&1
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									bump1_operstatus="up"
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							fi
						fi
						if [ -d /sys/class/bypass/g3bp1 ]; then
							if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
								if [ $model_type == "tiny" ]; then
									# check interface thread hang
									if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
										if ps -elL | grep $virt_port_4 >/dev/null 2>&1; then
											bump2_operstatus="up"
										fi
									else
										stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
										for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
											reboot
										done
									fi
								else
									# check interface thread hang
									if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
										bump2_operstatus="up"
									else
										stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
										for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
											reboot
										done
									fi
								fi
							fi
						fi
					fi
				else
					if [ -e /sys/class/niagara/niagara0/0/relay_status ]; then
						if [ "$bitw_port_1_enable" == "Enabled" ] && [ "$bitw_port_2_enable" == "Enabled" ]; then
							if [ $model_type == "tiny" ]; then
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									if ps -elL | grep $virt_port_2 >/dev/null 2>&1; then
										bump1_operstatus="up"
									fi
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							else
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									bump1_operstatus="up"
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							fi
						fi
					fi
					if [ -e /sys/class/niagara/niagara1/0/relay_status ]; then
						if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
							if [ $model_type == "tiny" ]; then
								# check interface thread hang
								if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
									if ps -elL | grep $virt_port_4 >/dev/null 2>&1; then
										bump2_operstatus="up"
									fi
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							else
								# check interface thread hang
								if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
									bump2_operstatus="up"
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							fi
						fi
					fi
				fi
			fi
		fi
	fi
	if [ ! -z $bitw2_port_2_adminstatus ]; then
		if [ "$bitw2_port_1_adminstatus" == "up" ]; then
			if [ "$bitw2_port_2_adminstatus" == "up" ]; then
				if [ "$bump2_type" == "cooper" ]; then
					if [ -d /sys/class/bypass/g3bp0 ]; then
						if [ "$bitw_port_1_enable" == "Enabled" ] && [ "$bitw_port_2_enable" == "Enabled" ]; then
							if [ $model_type == "tiny" ]; then
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									if ps -elL | grep $virt_port_2 >/dev/null 2>&1; then
										bump1_operstatus="up"
									fi
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							else
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									bump1_operstatus="up"
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							fi
						fi
						if [ -d /sys/class/bypass/g3bp1 ]; then
							if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
								if [ $model_type == "tiny" ]; then
									# check interface thread hang
									if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
										if ps -elL | grep $virt_port_4 >/dev/null 2>&1; then
											bump2_operstatus="up"
										fi
									else
										stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
										for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
											reboot
										done
									fi
								else
									# check interface thread hang
									if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
										bump2_operstatus="up"
									else
										stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
										for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
											reboot
										done
									fi
								fi
							fi
						fi
					fi
				else
					if [ -e /sys/class/niagara/niagara0/0/relay_status ]; then
						if [ "$bitw_port_1_enable" == "Enabled" ] && [ "$bitw_port_2_enable" == "Enabled" ]; then
							if [ $model_type == "tiny" ]; then
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									if ps -elL | grep $virt_port_2 >/dev/null 2>&1; then
										bump1_operstatus="up"
									fi
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							else
								# check interface thread hang
								if ps -elL | grep $virt_port_1 >/dev/null 2>&1; then
									bump1_operstatus="up"
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							fi
						fi
					fi
					if [ -e /sys/class/niagara/niagara1/0/relay_status ]; then
						if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
							if [ $model_type == "tiny" ]; then
								# check interface thread hang
								if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
									if ps -elL | grep $virt_port_4 >/dev/null 2>&1; then
										bump2_operstatus="up"
									fi
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							else
								# check interface thread hang
								if ps -elL | grep $virt_port_3 >/dev/null 2>&1; then
									bump2_operstatus="up"
								else
									stm_process_num=($(ps -ef | grep stm$ | awk '{print $2}'))
									for ((i = 0; i < ${#stm_process_num[@]}; i++)); do
										reboot
									done
								fi
							fi
						fi
					fi
				fi
			fi
		fi
	fi
	# logging bump's status.
	echo "Bump1 operstatus" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	echo $bump1_operstatus | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	echo "================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	echo "Bump2 operstatus" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	echo $bump2_operstatus | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	echo "================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log

	# case bump count is 2
	if [ $seg_count -eq 2 ]; then
		if [ "$bump1_operstatus" == "up" ]; then
			echo "bump1_operstatus up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			if [ "$bump2_operstatus" == "up" ]; then
				echo "bump2_operstatus up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
				stm_operstatus="up"
				echo "stm_operstatus up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
				echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			else
				echo "bump2 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
				echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			fi
		else
			echo "bump1 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			if [ "$bump2_operstatus" == "up" ]; then
				echo "bump2_operstatus up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
				echo "stm_operstatus not up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
				echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			else
				echo "bump2 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
				echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			fi
		fi
		# case bump count is 1
	else
		if [ "$bump1_operstatus" == "up" ]; then
			echo "bump1_operstatus up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			stm_operstatus="up"
			echo "stm_operstatus up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
		else
			echo "bump1 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
		fi
	fi
}

function rotate_log() {
	MAXLOG=5
	MAXSIZE=20480000
	log_name=/var/log/stm_bypass.log
	file_size=$(du -b $log_name | tr -s '\t' ' ' | cut -d' ' -f1)
	if [ $file_size -gt $MAXSIZE ]; then
		for i in $(seq $((MAXLOG - 1)) -1 1); do
			if [ -e $log_name"."$i ]; then
				mv $log_name"."{$i,$((i + 1))}
			fi
		done
		mv $log_name $log_name".1"
		touch $log_name
	fi
}

function fiber_module_check() {
	if [ "$bump_type" == "fiber" ]; then
		if [ -d /opt/stm/bypass_drivers/niagara/universal-driver-8b9_dpdk ]; then
			cd /opt/stm/bypass_drivers/niagara/universal-driver-8b9_dpdk/module
			network_bypass=$(lsmod | grep niagara | awk '{ print $1 }')
			if [ -z $network_bypass ]; then
				insmod niagara.ko
			fi
		fi
	fi
}

function disable_niagara_bypass()
{
  # first bump
	if [ $1 -eq 1 ]; then
    if [ "$bump1_operstatus" == "up" ]; then
      if [ "$bump_type" == "cooper" ]; then
        if [ -e /sys/class/niagara/niagara0/0/relay_status ]; then
          cd /sys/class/niagara/niagara0/0/
          bypass_status=$(cat relay_status)
          if [ "$bypass_status" != "2" ]; then
            echo "Disabling bypass on bump1" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
            ## mode enable d2 mode -> active : bypass
            sudo niagara_util -d0 0
            ## hb enable
            sudo niagara_util -a 0
          fi
        fi
      else
        if [ -e /sys/class/niagara/niagara0/0/relay_status ]; then
          cd /sys/class/niagara/niagara0/0/
          bypass_status=$(cat relay_status)
          if [ "$bypass_status" != "2" ]; then
            echo "Disabling bypass on bump1" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
            ## mode enable d2 mode -> active : bypass
            sudo niagara_util -d2 0
            ## hb enable
            sudo niagara_util -a 0
            ## hb disable
            #sudo niagara_util -r 0
          fi
        fi
    fi  
  fi
  # second bump
	if [ $1 -eq 2 ]; then
    if [ "$bump2_type" == "cooper" ]; then
      if [ -e /sys/class/niagara/niagara1/0/relay_status ]; then
        cd /sys/class/niagara/niagara1/0/
        bypass_status=$(cat relay_status)
        if [ "$bypass_status" != "2" ]; then
          echo "Disabling bypass on bump2" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
          ## mode enable d2 mode -> active : bypass
          sudo niagara_util -d0 0
          ## hb enable
          sudo niagara_util -a 0
        fi
      fi
    else
      if [ -e /sys/class/niagara/niagara1/0/relay_status ]; then
        cd /sys/class/niagara/niagara1/0/
        bypass_status=$(cat relay_status)
        if [ "$bypass_status" != "2" ]; then
          echo "Disabling bypass on bump2" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
          ## mode enable d2 mode -> active : bypass
          sudo niagara_util -d2 1
          ## hb enable : active
          sudo niagara_util -a 1
          ## hb disable : bypass
          #sudo niagara_util -r 0
        fi
      fi
    fi
  fi
}

function enable_niagara_bypass()
{
  # first bump
	if [ $1 -eq 1 ]; then
    if [ "$bump_type" == "cooper" ]; then
      if [ $bitw1_cooper_bypass != "1" ]; then
        echo "Enabling bypasses on bump1 " | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
        sudo niagara_util -r 0
      fi
    else
      if [ $bitw1_fiber_bypass != "1" ]; then
        echo "Enabling bypasses on bump1 " | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
        sudo niagara_util -r 0
      fi
    fi
  fi
  # second bump
	if [ $1 -eq 2 ]; then
    if [ "$bump2_type" == "cooper" ]; then
      if [ $bitw2_cooper_bypass != "1" ]; then
        echo "Enabling bypasses on bump2 " | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
        sudo niagara_util -r 1
      fi
    else
      if [ $bitw2_fiber_bypass != "1" ]; then
        echo "Enabling bypasses on bump2 " | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
        sudo niagara_util -r 1
      fi
    fi
  fi
}

functions check_bypass_status()
{
  if [ "$bump_type" == "cooper" ]; then
    if [ -e /sys/class/niagara/niagara0/0/relay_status ]; then
      bitw1_fiber_bypass=$(cat /sys/class/niagara/niagara0/0/relay_status)
    else
      bitw1_fiber_bypass='None'
    fi
    if [ -e /sys/class/niagara/niagara1/0/relay_status ]; then
      bitw2_fiber_bypass=$(cat /sys/class/niagara/niagara1/0/relay_status)
    else
      bitw2_fiber_bypass='None'
    fi
  else
    if [ -e /sys/class/niagara/niagara0/0/relay_status ]; then
      bitw1_fiber_bypass=$(cat /sys/class/niagara/niagara0/0/relay_status)
    else
      bitw1_fiber_bypass='None'
    fi
    if [ -e /sys/class/niagara/niagara1/0/relay_status ]; then
      bitw2_fiber_bypass=$(cat /sys/class/niagara/niagara1/0/relay_status)
    else
      bitw2_fiber_bypass='None'
    fi
  fi
}

function print_bypass_status()
{
  if [ "$bump_type" == "cooper" ]; then
    echo "cooper bypass status(bump1, bump2 | b=bypass, n=normal) : "$bitw1_cooper_bypass","$bitw2_cooper_bypass | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  else
    echo "fiber bypass status(bump1, bump2 | 1=bypass, 2=normal) : "$bitw1_fiber_bypass","$bitw2_fiber_bypass | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  fi
  echo "bump1's port1,2 : "$bitw_port_1_enable","$bitw_port_2_enable | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  echo "bump2's port1,2 : "$bitw2_port_1_enable","$bitw2_port_2_enable | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  echo "model type : "$model_type | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  echo "bump1's type, bump2's type : "$bump_type","$bump2_type | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  echo "segment count : "$seg_count | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  echo "stm's operstatus : "$stm_operstatus", bump1's status : "$bump1_operstatus" , bump2's status : "$bump2_operstatus | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
  echo "===========================" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
}

# main logic
# 1. get real and virt port
# 2. check type of bump (fiber) and do checking module is installed and loaded..
# 3. if stm_operstatus is down, just go checking bump's status again
# 4. if stm_operstatus is up and each bump's status is up, change bypass to normal mode for each bump if the status of bypass is bypass mode
# 5. if stm_operstatus is up and each bump's status is down, change bypass to bypass mode for each bump if the status of bypass is normal mode
echo "=== Start portwell-bypass-monitor === " | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
get_real_ports
check_bump_type
fiber_module_check
if [ "$int_type" != "QLogic" ]; then
	echo "It's not installed niagara card!!! Please install cards" | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
	exit 1
else
	while true; do
		rotate_log
		get_real_ports
		check_bump_type
		fiber_module_check

		if [ $stm_operstatus != "up" ]; then
			echo "stm_operstatus "$stm_operstatus | awk '{ print strftime(), $0; fflush() }' >>/var/log/stm_bypass.log
			check_bumps
		else
			### first bump check
			if [ "$bump1_operstatus" == "up" ]; then
				disable_niagara_bypass 1
				check_bumps
			else
        enable_niagara_bypass 1
        check_bumps
			fi
			### second bump check
			if [ $realint_count == "4" ]; then
				if [ "$bump2_operstatus" == "up" ]; then
					disable_niagara_bypass 2
					check_bumps
				else
          enable_niagara_bypass 2
					check_bumps
				fi
			fi
		fi
		# check bypass status
    check_bypass_status
		### print current bypass status
		print_bypass_status
		sleep 10
	done
fi
