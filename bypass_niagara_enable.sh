#!/bin/bash
rl="$(runlevel | awk '{ print $2  }')"
echo "runlevel is $rl" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
if [ "$rl" -eq 0  ]; then
	echo "runlevel is 0, forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
			sudo niagara_util -d1
			sudo niagara_util -r
		    sudo niagara_util -r 0
			sudo niagara_util -r 1
else
	if [ "$rl" -eq 6  ]; then
		echo "runlevel is 6, forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
		sudo niagara_util -d1
		sudo niagara_util -r
		sudo niagara_util -r 0
		sudo niagara_util -r 1
	fi
fi
echo "=== Completed bypass_niagara_enable.sh" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
