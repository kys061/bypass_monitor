#!/bin/bash
#
#####################################
# Copyright (c) 2017 Saise	    #
# Last Date : 2017.07.21	    #
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
# check files, before main
while ! $stm_status
do
echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |egrep '(Socket|Ethernet)' >/dev/null 2>&1
if [ $? -eq 0 ]; then
	version=$(echo 'show version' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |awk '{print $1}' |egrep 'V[0-9]+\.[0-9]+' -o)
	model_type=$(echo 'show parameter model' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |awk '{print $3}')
	if [ $version == "V7.1" ]; then
		if [ $model_type == "tiny" ]; then
		    bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |wc -l)
		else
		    bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |wc -l)
		fi
		stm_status='true'
		echo 'virt,real' > /etc/stm/system_virt_real_device.csv
		if [ $model_type == "tiny" ]; then
		    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
		else
		    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
		fi
		if [ ! -e /etc/stm/system_virt_real_device.csv  ]; then
			echo 'virt,real' > /etc/stm/system_virt_real_device.csv
			if [ $model_type == "tiny" ]; then
			    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
			else
			    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
			fi
			if [ $? -eq 1 ]; then
				sleep 10
				echo 'virt,real' > /etc/stm/system_virt_real_device.csv
				if [ $model_type == "tiny" ]; then
				    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
				else
				    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
				fi
			fi
		fi
	else
		if [ $model_type == "tiny" ]; then
                    bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |wc -l)
                else
                    bump_count=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |wc -l)
                fi
                stm_status='true'
		echo 'virt,real' > /etc/stm/system_virt_real_device.csv
		if [ $model_type == "tiny" ]; then
		    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
		else
		    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
		fi
                if [ ! -e /etc/stm/system_virt_real_device.csv  ]; then
                        echo 'virt,real' > /etc/stm/system_virt_real_device.csv
                        if [ $model_type == "tiny" ]; then
                            echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
                        else
                            echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
                        fi
                        if [ $? -eq 1 ]; then
                                sleep 10
                                echo 'virt,real' > /etc/stm/system_virt_real_device.csv
                                if [ $model_type == "tiny" ]; then
                                    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
                                else
                                    echo 'show interfaces select system_interface' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |awk '{print $1 "," $10; fflush()}' >> /etc/stm/system_virt_real_device.csv
                                fi
                        fi
                fi
	fi
fi
echo "stm setup is not enabled or not running.." | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
sleep 3
done

function get_real_ports
{
    if [ $version == "V7.1" ]; then
        realint_count=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |wc -l)
    else
	realint_count=$(echo 'show interfaces select interface system_interface' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |wc -l)
    fi
    for ((i=0; i<$realint_count; i++));
    do
        if [ $i == 0  ]; then
	        if [ $version == "V7.1" ]; then
	                virt_port_1_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 1 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
		else
			virt_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 1 {print}')
		fi
		if [[ $virt_port_1_index == '' ]]; then
			virt_port_1=''
			real_port_1=''
		else
			if [ $version == "V7.1" ]; then
	                virt_port_1=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_1_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
	                real_port_1=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_1 | cut -d "," -f2)
			else
	                virt_port_1=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_1_index |awk '{print $1}')
	                real_port_1=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_1 | cut -d "," -f2)
			fi
		fi
        elif [ $i == 1 ]; then
	        if [ $version == "V7.1" ]; then
                	virt_port_2_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 2 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
		else
			virt_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 2 {print}')
		fi
		if [[ $virt_port_2_index == '' ]]; then
			virt_port_2=''
			real_port_2=''
		else
			if [ $version == "V7.1" ]; then
	                virt_port_2=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_2_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
	                real_port_2=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_2 | cut -d "," -f2)
			else
	                virt_port_2=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_2_index |awk '{print $1}')
	                real_port_2=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_2 | cut -d "," -f2)
			fi
		fi
        elif [ $i == 2 ]; then
	        if [ $version == "V7.1" ]; then
			virt_port_3_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 3 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
		else
			virt_port_3_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 3 {print}')
		fi
		if [[ $virt_port_3_index == '' ]]; then
			virt_port_3=$virt_port_1
			real_port_3=$real_port_1
		else
			if [ $version == "V7.1" ]; then
			virt_port_3=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_3_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
			real_port_3=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_3 | cut -d "," -f2)
			else
	                virt_port_3=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_3_index |awk '{print $1}')
	                real_port_3=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_3 | cut -d "," -f2)
			fi
		fi
        elif [ $i == 3 ]; then
	        if [ $version == "V7.1" ]; then
			virt_port_4_index=$(snmpwalk -v 2c -c public localhost ifIndex |egrep 'INTEGER: [0-9]$' |awk 'FNR == 4 {print}' |cut -d " " -f1 |rev |cut -d "." -f1)
		else
			virt_port_4_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 4 {print}')
		fi
		if [[ $virt_port_4_index == '' ]]; then
			virt_port_4=$virt_port_2
			real_port_4=$real_port_2
		else
			if [ $version == "V7.1" ]; then
                	virt_port_4=$(snmpwalk -v 2c -c public localhost ifName |grep -m 1 ifName.$virt_port_4_index | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
	                real_port_4=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_4 | cut -d "," -f2)
			else
	                virt_port_4=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |grep $virt_port_4_index |awk '{print $1}')
	                real_port_4=$(cat /etc/stm/system_virt_real_device.csv |grep $virt_port_4 | cut -d "," -f2)
			fi
		fi
        fi
    done
}

function check_bump_type
{
    # check bump type
#    echo $real_port_1" "$real_port_3
    if [ $version == "V7.1" ]; then
    real_port_1_pci=$(cat /etc/stm/system_devices.csv |grep "$real_port_1\$" |awk -F"," '{print $2}' |cut -d":" -f2,3)
    real_port_3_pci=$(cat /etc/stm/system_devices.csv |grep "$real_port_3\$" |awk -F"," '{print $2}' |cut -d":" -f2,3)
    else
    real_port_1_pci=$(cat /etc/stm/devices.csv |grep "$real_port_1" |awk -F"," '{print $3}' |cut -d"\"" -f2 |cut -d":" -f2,3)
    real_port_3_pci=$(cat /etc/stm/devices.csv |grep "$real_port_3" |awk -F"," '{print $3}' |cut -d"\"" -f2 |cut -d":" -f2,3)
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
function check_model_type_enabled
{
    if [ $model_type == "tiny" ]; then
#	declare "bitw${2}_port_${1}_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |grep $real_port_1 |awk '{print $4}')"
	if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
	    bitw_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |grep $real_port_1 |awk '{print $4}')
	fi
	if [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
	    bitw_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |grep $real_port_2 |awk '{print $4}')
	fi
	if [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
	    bitw2_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |grep $real_port_3 |awk '{print $4}')
	fi
	if [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
	    bitw2_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Socket |grep $real_port_4 |awk '{print $4}')
	fi
    else
	if [ $1 -eq 1 ] && [ $2 -eq 1 ]; then
	    bitw_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_1 |awk '{print $6}')
	fi
	if [ $1 -eq 1 ] && [ $2 -eq 2 ]; then
	    bitw_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_2 |awk '{print $6}')
	fi
	if [ $1 -eq 2 ] && [ $2 -eq 1 ]; then
	    bitw2_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_3 |awk '{print $6}')
	fi
	if [ $1 -eq 2 ] && [ $2 -eq 2 ]; then
	    bitw2_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_4 |awk '{print $6}')
	fi
#	declare "bitw${2}_port_${1}_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_1 |awk '{print $4}')"
    fi
}

function check_bumps
{
        bitw_port_1=$virt_port_1
        bitw_port_2=$virt_port_2
        port3=$virt_port_3
        port4=$virt_port_4
#	bitw_port_1=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 1 -v "." | tail -n 1)
#	bitw_port_2=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 2 -v "." | tail -n 1)
#	port3=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 3 -v "." | tail -n 1)
#	port4=$(snmpwalk -v 2c -c public localhost ifName | rev | cut -d " " -f1 | rev | fgrep -m 4 -v "." | tail -n 1)
	if [ ! -z $port3 ] && [ ! -z $port4 ] && [ "$port3" != "$bitw_port_1" ] && [ "$port3" != "$bitw_port_2" ] && [ "$port4" != "$bitw_port_1" ] && [ "$port4" != "$bitw_port_2" ]; then
	    bitw2_port_1=$port3
	    bitw2_port_2=$port4
            seg_count=2
        else
            seg_count=1
	fi

	if [ ! -z $bitw_port_1 ]; then
	    if [ "$bitw_port_1" != "tree)" ]; then
		if [ $version == "V7.1" ]; then
		bitw_port_1_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw_port_1 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw_port_1_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_1_index | cut -d" " -f4 |awk -F"(" '{print $1}')
#		bitw_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_1 |awk '{print $4}')
		check_model_type_enabled 1 1
		bitw_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
#		bitw_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
		else
		bitw_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 1 {print}')
		bitw_port_1_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep $bitw_port_1_index |awk '{print $13}')
		bitw_port_1_adminstatus=$(echo "$bitw_port_1_adminstatus" |awk '{print tolower($0)}')
		check_model_type_enabled 1 1
		fi
	    fi
	fi
	if [ ! -z $bitw_port_1_adminstatus ]; then
	    if [ ! -z $bitw_port_2 ]; then
		if [ $version == "V7.1" ]; then
		bitw_port_2_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw_port_2 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw_port_2_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw_port_2_index | cut -d " " -f4 |awk -F"(" '{print $1}')
#		bitw_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_2 |awk '{print $4}')
		check_model_type_enabled 1 2
                bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
#		bitw_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
		else
		bitw_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 2 {print}')
		bitw_port_2_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep $bitw_port_2_index |awk '{print $13}')
		bitw_port_2_adminstatus=$(echo "$bitw_port_2_adminstatus" |awk '{print tolower($0)}')
		check_model_type_enabled 1 2
		fi
	    fi
	fi
	if [ ! -z $bitw2_port_1 ]; then
	    if [ "$bitw_port_1" != "tree)" ]; then
		if [ $version == "V7.1" ]; then
		bitw2_port_1_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw2_port_1 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw2_port_1_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw2_port_1_index | cut -d" " -f4 |awk -F"(" '{print $1}')
#		bitw2_port_1_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_3 |awk '{print $4}')
		check_model_type_enabled 2 1
                bitw2_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_3 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
#		bitw2_port_1_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw2_port_1 | cut -d "," -f2 | sed 's/\://g' | sed 's/\.//g')
		else
		bitw2_port_1_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 3 {print}')
		bitw2_port_1_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep $bitw2_port_1_index |awk '{print $13}')
		bitw2_port_1_adminstatus=$(echo "$bitw2_port_1_adminstatus" |awk '{print tolower($0)}')
		check_model_type_enabled 2 1
		fi
	    fi
	fi
	if [ ! -z $bitw2_port_1_adminstatus ]; then
	    if [ ! -z $bitw2_port_2 ]; then
		if [ $version == "V7.1" ]; then
		bitw2_port_2_index=$(snmpwalk -v 2c -c public localhost ifName | grep -m 1 $bitw2_port_2 | cut -d " " -f1 | rev | cut -d "." -f1)
		bitw2_port_2_adminstatus=$(snmpget -v 2c -c public localhost ifAdminStatus.$bitw2_port_2_index | cut -d " " -f4 |awk -F"(" '{print $1}')
#		bitw2_port_2_enable=$(echo 'show interfaces' | sudo /opt/stm/target/pcli/stm_cli.py $id:$pass@localhost |grep Ethernet |grep $real_port_4 |awk '{print $4}')
		check_model_type_enabled 2 2
                bitw2_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $real_port_4 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
#		bitw2_port_2_pci=$(cat /etc/stm/system_interfaces.csv | grep $bitw_port_2 | cut -d"," -f2 | sed 's/\://g' | sed 's/\.//g')
		else
		bitw2_port_2_index=$(echo 'show interfaces select interface system_interface uid' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep Ethernet |awk '{print $10}' |awk 'FNR == 4 {print}')
		bitw2_port_2_adminstatus=$(echo 'show interfaces select interface system_interface uid admin_status' | sudo /opt/stm/target/pcli/stm_cli.py admin:admin@localhost |grep $bitw2_port_2_index |awk '{print $13}')
		bitw2_port_2_adminstatus=$(echo "$bitw2_port_2_adminstatus" |awk '{print tolower($0)}')
		check_model_type_enabled 2 2
		fi
	    fi
	fi
	if [ ! -z $bitw_port_2_adminstatus ]; then
	    if [ "$bitw_port_1_adminstatus" == "up" ]; then
		if [ "$bitw_port_2_adminstatus" == "up" ]; then
		    if [ "$bump_type" == "cooper" ]; then
			    if [ -d /sys/class/bypass/g3bp0 ]; then
#				bump1_port0_pci=$(ls -l /sys/class/bypass/g3bp0/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#				bump1_port1_pci=$(ls -l /sys/class/bypass/g3bp0/port1/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#				if [ "$bitw_port_1_pci" == "$bump1_port0_pci" ] || [ "$bitw_port_2_pci" == "$bump1_port0_pci" ]; then
				    if [ $bitw_port_1_enable == "Enabled" ] && [ $bitw_port_2_enable == "Enabled" ]; then
				        if [ $model_type == "tiny" ]; then
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    ps -elL |grep $virt_port_2 >/dev/null 2>&1
						    if [ $? -eq 0 ]; then
						        bump1_operstatus="up"
						    fi
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					else
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    bump1_operstatus="up"
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					fi
				    fi
#				else 
				    if [ -d /sys/class/bypass/g3bp1 ]; then
#					bump2_port0_pci=$(ls -l /sys/class/bypass/g3bp1/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#					bump2_port1_pci=$(ls -l /sys/class/bypass/g3bp1/port1/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#					if [ "$bitw_port_1_pci" == "$bump2_port0_pci" ] || [ "$bitw_port_2_pci" == "$bump2_port0_pci" ]; then
					    if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
						if [ $model_type == "tiny" ]; then
							# check process hang
							ps -elL |grep $virt_port_3 >/dev/null 2>&1
							if [ $? -eq 0 ]; then
							    ps -elL |grep $virt_port_4 >/dev/null 2>&1
							    if [ $? -eq 0 ]; then
							        bump2_operstatus="up"
							    fi
							else
							    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
							    for ((i=0; i<${#stm_process_num[@]}; i++));
							    do
								kill -9 ${stm_process_num[$i]}
							    done
							fi
						else
							# check process hang
							ps -elL |grep $virt_port_3 >/dev/null 2>&1
							if [ $? -eq 0 ]; then
								bump2_operstatus="up"
							else
							    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
							    for ((i=0; i<${#stm_process_num[@]}; i++));
							    do
								kill -9 ${stm_process_num[$i]}
							    done
							fi
						fi
					    fi
#					fi
				    fi
#				fi
			    fi
		    else
			    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass0 ]; then
				if [ "$bitw_port_1_enable" == "Enabled" ] && [ "$bitw_port_2_enable" == "Enabled" ]; then
				        if [ $model_type == "tiny" ]; then
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    ps -elL |grep $virt_port_2 >/dev/null 2>&1
						    if [ $? -eq 0 ]; then
						        bump1_operstatus="up"
						    fi
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					else
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    bump1_operstatus="up"
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					fi
			        fi
			    fi
			    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass1 ]; then
			        if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
					if [ $model_type == "tiny" ]; then
						# check process hang
						ps -elL |grep $virt_port_3 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    ps -elL |grep $virt_port_4 >/dev/null 2>&1
							if [ $? -eq 0 ]; then
							    bump2_operstatus="up"
							fi
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					else
						# check process hang
						ps -elL |grep $virt_port_3 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
							bump2_operstatus="up"
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
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
#				bump1_port0_pci=$(ls -l /sys/class/bypass/g3bp0/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#				bump1_port1_pci=$(ls -l /sys/class/bypass/g3bp0/port1/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#				if [ "$bitw2_port_1_pci" == "$bump1_port0_pci" ] || [ "$bitw2_port_2_pci" == "$bump1_port0_pci" ]; then
				    if [ "$bitw_port_1_enable" == "Enabled" ] && [ "$bitw_port_2_enable" == "Enabled" ]; then
				        if [ $model_type == "tiny" ]; then
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    ps -elL |grep $virt_port_2 >/dev/null 2>&1
						    if [ $? -eq 0 ]; then
						        bump1_operstatus="up"
						    fi
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					else
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    bump1_operstatus="up"
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					fi
				    fi
#				else 
				    if [ -d /sys/class/bypass/g3bp1 ]; then
#					bump2_port0_pci=$(ls -l /sys/class/bypass/g3bp1/port0/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#					bump2_port1_pci=$(ls -l /sys/class/bypass/g3bp1/port1/ | grep pci: | rev | cut -d":" -f1 | rev | sed -r 's/^.{2}//')
#					if [ "$bitw2_port_1_pci" == "$bump2_port0_pci" ] || [ "$bitw2_port_2_pci" == "$bump2_port0_pci" ]; then
					    if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
						if [ $model_type == "tiny" ]; then
							# check process hang
							ps -elL |grep $virt_port_3 >/dev/null 2>&1
							if [ $? -eq 0 ]; then
							    ps -elL |grep $virt_port_4 >/dev/null 2>&1
							    if [ $? -eq 0 ]; then
							        bump2_operstatus="up"
							    fi
							else
							    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
							    for ((i=0; i<${#stm_process_num[@]}; i++));
							    do
								kill -9 ${stm_process_num[$i]}
							    done
							fi
						else
							# check process hang
							ps -elL |grep $virt_port_3 >/dev/null 2>&1
							if [ $? -eq 0 ]; then
								bump2_operstatus="up"
							else
							    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
							    for ((i=0; i<${#stm_process_num[@]}; i++));
							    do
								kill -9 ${stm_process_num[$i]}
							    done
							fi
						fi
					    fi
#					fi
				    fi
#				fi
			    fi
		    else
			    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass0 ]; then
				if [ "$bitw_port_1_enable" == "Enabled" ] && [ "$bitw_port_2_enable" == "Enabled" ]; then
				        if [ $model_type == "tiny" ]; then
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    ps -elL |grep $virt_port_2 >/dev/null 2>&1
						    if [ $? -eq 0 ]; then
						        bump1_operstatus="up"
						    fi
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					else
						# check process hang
						ps -elL |grep $virt_port_1 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    bump1_operstatus="up"
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					fi
			        fi
			    fi
			    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass1 ]; then
			        if [ "$bitw2_port_1_enable" == "Enabled" ] && [ "$bitw2_port_2_enable" == "Enabled" ]; then
					if [ $model_type == "tiny" ]; then
						# check process hang
						ps -elL |grep $virt_port_3 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
						    ps -elL |grep $virt_port_4 >/dev/null 2>&1
							if [ $? -eq 0 ]; then
							    bump2_operstatus="up"
							fi
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					else
						# check process hang
						ps -elL |grep $virt_port_3 >/dev/null 2>&1
						if [ $? -eq 0 ]; then
							bump2_operstatus="up"
						else
						    stm_process_num=($(ps -ef |grep stm$ |awk '{print $2}'))
						    for ((i=0; i<${#stm_process_num[@]}; i++));
						    do
							kill -9 ${stm_process_num[$i]}
						    done
						fi
					fi
				fi
			    fi
		    fi
		fi
	    fi	    
	fi

       	echo "Bump1 operstatus" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo $bump1_operstatus  | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo "================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo "Bump2 operstatus" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo $bump2_operstatus  | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	echo "================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	
    if [ $seg_count -eq 2 ]; then
	if [ "$bump1_operstatus" == "up" ]; then
	    echo "bump1_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    if [ "$bump2_operstatus" == "up" ]; then
		echo "bump2_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
		stm_operstatus="up"
		echo "stm_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    		echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    else
	        echo "bump2 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    		echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    fi
	else
	    echo "bump1 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    if [ "$bump2_operstatus" == "up" ]; then
		echo "bump2_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
		echo "stm_operstatus not up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    		echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    else
	        echo "bump2 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    		echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    fi
	fi
    else
	if [ "$bump1_operstatus" == "up" ]; then
	    echo "bump1_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	    stm_operstatus="up"
	    echo "stm_operstatus up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    	    echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	else
	    echo "bump1 operstatus not up" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    	    echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	fi
    fi
}

# main
echo "=== Start portwell-bypass-monitor === " | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
get_real_ports
check_bump_type
if [ "$bump_type" == "fiber" ]; then
	if [ -d /opt/stm/bypass_drivers/portwell_fiber/driver ]; then
	    cd /opt/stm/bypass_drivers/portwell_fiber/driver
	    network_bypass=$(lsmod |grep network_bypass |awk '{ print $1 }')
            i2c_i801=$(lsmod |grep i2c_i801 |awk '{ print $1 }')
	    if [ -z $i2c_i801 ]; then
	        modprobe i2c-i801
	    fi
	    if [ -z $network_bypass ]; then
	        insmod network-bypass.ko board=CAR3040
	    fi
	fi
fi

while true
do 
    get_real_ports
    check_bump_type
    if [ "$bump_type" == "fiber" ]; then
        if [ -d /opt/stm/bypass_drivers/portwell_fiber/driver ]; then
	    cd /opt/stm/bypass_drivers/portwell_fiber/driver
	    network_bypass=$(lsmod |grep network_bypass |awk '{ print $1 }')
            i2c_i801=$(lsmod |grep i2c_i801 |awk '{ print $1 }')
	    if [ -z $i2c_i801 ]; then
	        modprobe i2c-i801
	    fi
	    if [ -z $network_bypass ]; then
	        insmod network-bypass.ko board=CAR3040
	    fi
        fi
    fi
    if [ $stm_operstatus != "up" ]; then
	echo "stm_operstatus "$stm_operstatus | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#	echo "Enabling bypasses on bump1 and bump2 due to ongoing core dump operation" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#	/opt/stm/target/enable_bypass.sh
	check_bumps
    else
	if [ "$bump1_operstatus" == "up" ]; then
	    if [ "$bump_type" == "cooper" ]; then
		    if [ -d /sys/class/bypass/g3bp0 ]; then
			cd /sys/class/bypass/g3bp0
			bypass_status=$(cat bypass)
#		        echo "Bypass Status"
#		        echo $bypass_status 
			if [ "$bypass_status" != "n" ]; then 
			    echo "Disabling bypass on bump1" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
			    echo 1 > func
			    echo n > bypass
			fi
		    fi
	    else
		    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass0 ]; then
			cd /sys/class/misc/caswell_bpgen2/slot0/
			bypass_status=$(cat bypass0)
#		        echo "Bypass Status"
#		        echo "Bypass Status : "$bypass_status"; 0 is Normal, 2 is Bypass" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
			if [ "$bypass_status" != "0" ]; then 
			    echo "Disabling bypass on bump1" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#			    echo 1 > func
			    echo 0 > bypass0
			fi
		    fi
	    fi
	    check_bumps
	else
	    if [ "$bump_type" == "cooper" ]; then
	        if [ $bitw1_cooper_bypass != "b" ]; then
	    	    echo "Enabling bypasses on bump1 " | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	 	    /opt/stm/target/enable_bypass.sh bump1
		    check_bumps
		fi
	    else
		if [ $bitw1_fiber_bypass != "2" ]; then
	    	    echo "Enabling bypasses on bump1 " | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	 	    /opt/stm/target/enable_bypass.sh bump1
		    check_bumps
		fi
            fi
	fi

	if [ "$bump2_operstatus" == "up" ]; then
	    if [ "$bump2_type" == "cooper" ]; then
		    if [ -d /sys/class/bypass/g3bp1 ]; then
			cd /sys/class/bypass/g3bp1
			bypass_status=$(cat bypass)
#		        echo "Bypass Status"
#		        echo $bypass_status 
			if [ "$bypass_status" != "n" ]; then 
			    echo "Disabling bypass on bump2" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
			    echo 1 > func
			    echo n > bypass
			fi
		    fi
	    else
		    if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass1 ]; then
			cd /sys/class/misc/caswell_bpgen2/slot0/
			bypass_status=$(cat bypass1)
#		        echo "Bypass Status"
#		        echo "Bypass Status : "$bypass_status"; 0 is Normal, 2 is Bypass" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
			if [ "$bypass_status" != "0" ]; then 
			    echo "Disabling bypass on bump2" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#			    echo 1 > func
			    echo 0 > bypass1
			fi
		    fi
	    fi
	    check_bumps
	else
	    if [ "$bump2_type" == "cooper" ]; then
	        if [ $bitw2_cooper_bypass != "b" ]; then
	    	    echo "Enabling bypasses on bump2 " | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	 	    /opt/stm/target/enable_bypass.sh bump2
		    check_bumps
		fi
	    else
		if [ $bitw2_fiber_bypass != "2" ]; then
	    	    echo "Enabling bypasses on bump2 " | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
	 	    /opt/stm/target/enable_bypass.sh bump2
		    check_bumps
		fi
            fi
	fi
    fi
    # check bypass status
    if [ "$bump_type" == "cooper" ]; then
        if [ -d /sys/class/bypass/g3bp0 ]; then
            bitw1_cooper_bypass=$(cat /sys/class/bypass/g3bp0/bypass)
        else
            bitw1_cooper_bypass='None'
        fi
        if [ -d /sys/class/bypass/g3bp1 ]; then
            bitw2_cooper_bypass=$(cat /sys/class/bypass/g3bp1/bypass)
        else
            bitw2_cooper_bypass='None'
        fi
    else
        if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass0 ]; then
            bitw1_fiber_bypass=$(cat /sys/class/misc/caswell_bpgen2/slot0/bypass0)
        else
            bitw1_fiber_bypass='None'
        fi
        if [ -e /sys/class/misc/caswell_bpgen2/slot0/bypass1 ]; then
            bitw2_fiber_bypass=$(cat /sys/class/misc/caswell_bpgen2/slot0/bypass1)
        else
            bitw2_fiber_bypass='None'
        fi
    fi
#    echo "virt1, 2, 3, 4 : "$virt_port_1","$virt_port_2","$virt_port_3","$virt_port_4 | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    if [ "$bump_type" == "cooper" ]; then
    	echo "cooper bypass status(bump1, bump2 | b=bypass, n=normal) : "$bitw1_cooper_bypass","$bitw2_cooper_bypass | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    else
	echo "fiber bypass status(bump1, bump2 | 2=bypass, 0=normal) : "$bitw1_fiber_bypass","$bitw2_fiber_bypass | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    fi
    echo "bump1's port1,2 : "$bitw_port_1_enable","$bitw_port_2_enable | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    echo "bump2's port1,2 : "$bitw2_port_1_enable","$bitw2_port_2_enable | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    echo "model type : "$model_type | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    echo "bump1's type, bump2's type : "$bump_type","$bump2_type | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    echo "segment count : "$seg_count | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    echo "stm's operstatus : "$stm_operstatus", bump1's status : "$bump1_operstatus" , bump2's status : "$bump2_operstatus | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
    echo "===========================" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#    echo $bump1_port0_pci" : "$bump1_port1_pci" : "$bump2_port0_pci" : "$bump2_port1_pci | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#    sleep 2
#    if [ -f /opt/stm/target/core ]; then
#	echo "Enabling bypasses on bump1 and bump2 due to ongoing core dump operation" | awk '{ print strftime(), $0; fflush() }' >> /var/log/stm_bypass.log
#	/opt/stm/target/enable_bypass.sh
#	exit 0
#    fi
    sleep 10
done

