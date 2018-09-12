#!/bin/bash
kernel_ver=4.15.0-20-generic
uname_r=$(uname -r)

if [ "$uname_r" = "$kernel_ver" ]; then
	echo "Forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
	sudo bpctl_util all set_bypass on >/dev/null 2>&1
else
	rl="$(runlevel | awk '{ print $2  }')"
	echo "runlevel is $rl" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
	if [ "$rl" -eq 0  ]; then
		echo "runlevel is 0, forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
		sudo bpctl_util all set_dis_bypass off >/dev/null 2>&1 
		sudo bpctl_util all set_bypass on >/dev/null 2>&1
		sudo bpctl_util all set_bypass_pwoff on >/dev/null 2>&1
		sudo bpctl_util all set_bypass_pwup on >/dev/null 2>&1
	else
		if [ "$rl" -eq 6  ]; then
			echo "runlevel is 6, forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
			sudo bpctl_util all set_dis_bypass off >/dev/null 2>&1
			sudo bpctl_util all set_bypass on >/dev/null 2>&1
			sudo bpctl_util all set_bypass_pwoff on >/dev/null 2>&1
			sudo bpctl_util all set_bypass_pwup on >/dev/null 2>&1		
		fi
	fi
fi

echo "=== Completed ${0##*/} ===" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
