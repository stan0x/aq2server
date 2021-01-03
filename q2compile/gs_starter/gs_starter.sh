#!/usr/bin/env bash
# gs_starter.sh - Tool for managing unix screens with bash. Typically game servers.
# ----------------------------------------------------------------
# Copyright (C) 2012 Paul-Dieter Klumpp
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ----------------------------------------------------------------
#
# bash is needed!!
#
# by Paul Klumpp, 2012-11-14
#
# gs_starter.cfg is part of gs_starter.sh
#
##### now, hands away... #####
# if [ "${SHELL}" != "$(which bash)" ]; then
	# echo "Start this script with bash!"
	# exit
# fi
function loadcfg() {
	if [ -f "gs_starter.cfg" ]; then
		. "./gs_starter.cfg"
	else
		echo "The gs_starter.cfg is not there! Won't work without! Exiting"
		return 0
	fi

	for idx in ${!ACTIVATE[*]}; do
		SCREEN[${ACTIVATE[$idx]}]="${PREFIX}${ACTIVATE[$idx]}"
	done
	#echo ${ACTIVATE[*]} vs ${OLD_ACTIVATE[*]}
	if [ "${ACTIVATE[*]}" != "${OLD_ACTIVATE[*]}" ]; then
		if [ "$1" != "first" ]; then 
			echo "Lets keep those activated: ${SCREEN[*]}"
		fi
	fi
	OLD_ACTIVATE=${ACTIVATE[*]}
}

s_lib=""

function start_instance() {
	PARMS=${PARMS[$1]}
	if [ "$PARMS" != "" ]; then
		# if it still runs, don't start again
		SCR=${PREFIX}$1
		if [ "$SCR" != "" ]; then
			printf "."
		fi

		running=$(screen -list | grep -vi "dead" | grep -i "$SCR" | awk {'print $1'} | wc -l)
		if [ $running -eq 0 ]; then
			#start it daemonized via screen
			shellscript="${PREFIX}-$1.sh"
cat > $shellscript <<here-doc
#!/usr/bin/env bash
#file created by gs_starter.sh - Don't edit. Your changes will be overwritten!
while true; do
  echo
  echo "Starting '${GSDED} ${PARMS}' $s_lib"
  echo
  LD_LIBRARY_PATH=${s_lib} ./${GSDED} ${PARMS}
  echo
  echo "----sleep---- ctrl+c to hit the break :-)"
  echo
  sleep 3
done
here-doc
			chmod u+x $shellscript
			echo "Starting '${GSDED} ${PARMS}' $s_lib"
			screen -dm -S "${SCR}" "./$shellscript"
			echo "on screen: ${SCR}"
		fi
	fi
}


function find_filebits {
	Q64=$(file "${1}" | grep -i "x86-64" | wc -l)
	if [ "${Q64}" == "1" ]; then
		echo 64
		return 1
	fi

	Q32=$(file "${1}" | grep -i "32-bit" | wc -l)
	if [ "${Q32}" == "1" ]; then
		echo 32
		return 1
	fi

	# fallback and assume system bits
	sb=$(find_sysbits)
	echo $sb
	return 1
}

function find_sysbits {
	S64=$(uname -a | grep -i "x86_64" | wc -l)
	if [ "${S64}" == "1" ]; then
		echo 64
	else
		echo 32
	fi
}



function f_realpath() {
	RPBIN=$(which realpath)
	if [ -x "${RPBIN}" ]; then
		echo $(realpath "${1}")
	else
		echo ${1}
	fi
}

function control_c {
	if [ -f "gs_starter.run" ]; then
		rm "gs_starter.run"
	fi
	exit $?
}

function watcher {
	echo "Watcher begins..."
	# trap keyboard interrupt (control-c)
	trap control_c SIGINT
	echo "watcher runs" > "gs_starter.run"

	echo "Lets keep those activated: ${SCREEN[*]}"
	# start them..
	while [ -f "gs_starter.run" ]; do

		for index in ${!ACTIVATE[*]}
		do
			#start, if not running .. checks if running are in start_instance
			start_instance ${ACTIVATE[$index]}
		done

		sleep 4

		loadcfg

	done
}

function checkinstalled {
	if [ "$1" != "" ]; then
		I=$(which "$1" 2> /dev/null)
		if [ -f "$I" ]; then
			echo 1
		else
			echo 0
		fi
	fi
}

function main {

	loadcfg first

	if [ "$(checkinstalled "realpath")" == "1" ]; then
		RPQ=$(realpath "$GSDED")
	else
		RPQ=$GSDED
	fi

	FBITS=$(find_filebits $RPQ)
	SBITS=$(find_sysbits)
	#echo fbits: $FBITS
	#echo sbits: $SBITS

	#if [ $SBITS -gt $FBITS ]; then
	#	# link to 32bit libs 
	#	s_lib="lib32/"
	#fi

	if [ $SBITS -lt $FBITS ]; then
		echo "Can't start 64 bit executables ($GSDED) on this system."
		return 0
	fi

	#lib dir for ppl
	s_lib="LD_LIBRARY_PATH=libs/:$LD_LIBRARY_PATH"


	if [ "$1" == "" ]; then
		echo "Usage: gs_starter.sh <startwatch|stopwatch|stopall|start <instance#>|stop <instance#>>"
		return 1
	elif [ "$1" == "startwatch" ] || [ "$1" == "startall" ]; then
		ACTION="watch"
		# check if watcher is already running
		if [ -f "gs_starter.run" ]; then
			echo "gs_starter.sh is already running. Not starting again."
			return 0
		else
			watcher
			return 1
		fi
	elif [ "$1" == "stopwatch" ]; then
		rm "gs_starter.run"
		echo "The gs_starter watcher should be stopped now."
		return 1

	elif [ "$1" == "stopall" ]; then
		echo "Stopping all instances."
		echo "Pro-Tip: If the watcher is running, the servers will come up again. Useful to restart all instances."
		# find all screens with "$PREFIX"
		SCRPIDLIST=$(screen -ls | grep -i \.$PREFIX | cut -f1 -d\. | awk {'print $1'})
		for x in $SCRPIDLIST; do
			kill -9 $x
		done
		screen -wipe > /dev/null
		return 1

	elif [ "$1" == "start" ]; then
		if [ "$2" != "" ]; then
			NUMBER=$2
			echo "Starting instance $NUMBER."
			echo "Pro-Tip: If you want the watcher to watch this instance, edit gs_starter.cfg parameter ACTIVATE now."
			echo "         The watcher reloads the config and will begin watching it."
			# find all screens with "$PREFIX$NUMBER"
			start_instance $NUMBER
			return 1
		else
			echo "Usage: gs_starter.sh start <instance#>"
			return 0
		fi

	elif [ "$1" == "stop" ]; then
		if [ "$2" != "" ]; then
			NUMBER=$2
			echo "Stopping instance $NUMBER."
			echo "Pro-Tip: If the watcher is running, it may come up again. So this is useful for restarting with different PARMS."
			# find all screens with "$PREFIX$NUMBER"
			SCRPID=$(screen -ls | grep -i \.$PREFIX$NUMBER | cut -f1 -d\. | awk {'print $1'})
			kill -9 $SCRPID
			screen -wipe
			return 1
		else
			echo "Usage: gs_starter.sh stop <instance#>"
			return 0
		fi

	fi



}

main $*

# vim: tabstop=2 shiftwidth=2 softtabstop=2 autoindent:
# kate: space-indent off; indent-width 2; mixedindent off;
