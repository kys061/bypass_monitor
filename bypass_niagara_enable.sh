#!/bin/bash
rl="$(runlevel | awk '{ print $2  }')"
echo $(date -Iseconds) "runlevel is $rl" >> /var/log/stm_bypass.log
if [ "$rl" -eq 0  ]; then
	    echo $(date -Iseconds) "runlevel is 0, forcing bypass" >> /var/log/stm_bypass.log
		    sudo niagara_util -r 0
			sudo niagara_util -r 1
else
	if [ "$rl" -eq 6  ]; then
		echo $(date -Iseconds) "runlevel is 6, forcing bypass" >> /var/log/stm_bypass.log
		sudo niagara_util -r 0
		sudo niagara_util -r 1
	fi
fi
echo $(date -Iseconds) "=== Completed bypass_niagara_enable.sh" >> /var/log/stm_bypass.log
