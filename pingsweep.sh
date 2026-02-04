#!/bin/bash
# Ping sweep the Lab

cmd_ping() {
	#local limits the scope for a variable to just that function
	local logfile=ping.log
	local base="onyxnode"
	local found=0
	local total=0

	> ${logfile}

	echo "Pinging Nodes..."

	for q in {1..200}
	do
        	curr="$base$q"
        	#ping -c 1 $curr &> /dev/null
		ping -c 1 $curr >> ${logfile}

		if [ $? -eq 0 ]; then
			#ping -c 1 $curr >> ${logfile}
			echo "Node ${curr} is reachable"
			found=$((found + 1))
		else
			echo "Node ${curr} is not reachable"
		fi
		total=$((total + 1))
	done	

	local notFound=$((total - found))
	echo "Scanned ${total} nodes"
	echo "Found ${found} active machines"
	echo "No response from ${notFound} machines"
	echo "See ping.log for details"
}

cmd_help() {
	echo "[p ] ping" "run pingsweep.sh function"
	echo "[h ] help" "Show this help message"
}

main() {
	if [ $# -eq 0 ]; then
		# Exit by default
		cmd_help
		exit 0
	fi

	for cmd in "$@"; do
		case "$cmd" in
			ping|p) cmd_ping ;;
			help|h) cmd_help ;;
			*)
				echo "Unknown command: $cmd"
				cmd_help
				exit 1
				;;
		esac
   	done
}

main "$@"
