#!/bin/bash
# Ping sweep the Lab

pingsweep() {
	# clear previous log before scanning
	echo > ping.log 
	base="onyxnode"
	active_nodes=0
	inactive_nodes=0
	echo "Starting ping sweep..."
	for i in {1..200}; do 
		local node="${base}${i}"
		if ping -c 1 $node &> /dev/null; then 
			((active_nodes++))
		else 
			echo "no response from $node"
			((inactive_nodes++))
		fi
	done
	echo "Scanned 200 nodes." >> ping.log 
	echo "Found $active_nodes active machines." >> ping.log
	echo "No response from $inactive_nodes machines." >> ping.log
	echo "Done! Check the ping.log :)"
}

while getopts ":ph" flag; do 
	case $flag in 
		h) # handle -h flag (displays usage)
			echo "Help: This script accepts -p to perform a ping sweep and -h for help."
			;;
		p) # handle -p flag (performs ping sweep)
			pingsweep 
			;;  
	esac 
done

