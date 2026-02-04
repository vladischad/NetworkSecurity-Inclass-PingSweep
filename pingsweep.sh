#!/bin/bash
# Ping sweep the Lab

# Output: 
#	Scanned __ nodes 
#	Found __ active machines 
#   No response from ___ machines
#   See pingsweep.log for details 

pingsweep() {
	# clear previous log before scanning
	echo > ping.log 
	base="onyxnode"
	active_nodes=0
	inactive_nodes=0
	echo "Starting ping sweep..."
	for i in {1..50}; do 
		local node="${base}${i}"
		if ping -c 1 $node &> /dev/null; then 
			echo "active node found" 
			((active_nodes++))
		else 
			echo "no response from $node"
			((inactive_nodes++))
		fi
	done
	echo "Scanned 50 nodes." >> ping.log 
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

