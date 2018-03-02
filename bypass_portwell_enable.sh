#!/bin/bash
rl="$(runlevel | awk '{ print $2  }')"
echo "runlevel is $rl" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
if [ "$rl" -eq 0  ]; then
	echo "runlevel is 0, forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
	/opt/stm/target/enable_bypass.sh bump1
	/opt/stm/target/enable_bypass.sh bump2
else
	if [ "$rl" -eq 6  ]; then
		echo "runlevel is 6, forcing bypass" | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
		/opt/stm/target/enable_bypass.sh bump1
		/opt/stm/target/enable_bypass.sh bump2
	fi
fi
echo "=== Completed ${0##*/} " | awk '{ print strftime(), $0; fflush()  }' >> /var/log/stm_bypass.log
