#!/bin/bash
# Ping Sweep Script - IP range or hostname prefix

base="onyxnode"

ARGS=("$@")
# -h for help
# -p to run pinger

totalArgs=0
startRange=1
endRange=200

totalPorts=200
displayHelp=false
pingFoundCount=0

displayHelp() {
	echo "Usage: pingspammer.sh <options>"
	echo "Options:"
	echo "  -h        Display this help message (Prog term after display)"
	echo "  -p        Run the pinger from [1-200]"
	echo "  -v        Enable verbose output"
	echo "  -s , -e   Specify custom start and end for ping sweep (default 1-200)"
	echo -e "\n\n"
}
pingSweep() {
	echo "Starting ping sweep from $startRange to $endRange..."
	echo ""

	for i in $(seq "${startRange}" "${endRange}"); do
		curr="${base}${i}"
		ping -c 1 -W 1 "$curr" >>pingSweep.log
		# $? is the exit status of the last command run
		if [ $? -eq 0 ]; then
			pingFoundCount=$((pingFoundCount + 1))
			#     if [ "$verbose" = true ]; then
			#         echo "$curr is reachable."

			#     fi
			# else
			#     if [ "$verbose" = true ]; then
			#         echo "$curr is not reachable."
			#     fi
		fi
		percent=$(((i - startRange) * 100 / totalPorts))

		perMaxCharAmount=50
		percentStr="["

		for j in $(seq 1 $perMaxCharAmount); do
			if [ $j -le $((percent / 2)) ]; then
				percentStr=${percentStr}"*"
			else
				percentStr=${percentStr}"."
			fi
		done
		percentStr=${percentStr}"] "
		currPorts=$((i - startRange + 1))

		echo -en "\r\033[K ${percentStr} ${percent}% Checked: ${currPorts}/${totalPorts} hosts.]"
		# echo -en "\r\033[KReachable hosts found: $pingFoundCount"

	done
	echo -e "\n\n"

}

# for arg in "$@"
# do
#     if [ "$arg" == "-h" ]; then
#         displayHelp=true
#     elif [ "$arg" == "-p" ]; then
#         runPinger=true
#     fi
#     totalArgs=$((totalArgs + 1))
# done

# if [ "$displayHelp" == true ]; then
#     displayHelp
#     exit 0
# fi
# if [ "$runPinger" == true ]; then
#     echo "Would be running pinger..."
#     #Would run the pinger function here
# fi
# echo "Total arguments: $totalArgs"
verbose=false

while getopts "hvps:e:" opt; do
	case $opt in
	h)
		displayHelp
		exit 0
		;;
	v)
		verbose=true
		echo "Verbose mode enabled."
		;;
	p)
		pingSweep
		echo "Found $pingFoundCount reachable hosts."
		#echo "Pinger option selected."
		#Would run the pinger function here
		;;
	s)
		startRange=$OPTARG
		echo "Custom start range set to $startRange"
		;;
	e)
		endRange=$OPTARG
		echo "Custom end range set to $endRange"
		;;
	*)
		echo "Invalid options provided. Use -h for help."
		;;
	esac
	if [ "$endRange" -le "$startRange" ]; then
		echo "End range must be greater than start range."
		exit 1
	elif [ "$startRange" -lt 1 ] || [ "$endRange" -gt 255 ]; then
		echo "Start and end range must be between 1 and 255."
		exit 1
	fi
	totalPorts=$((endRange - startRange + 1))
done
if [ $OPTIND -eq 1 ]; then
	echo "No options were passed. Use -h for help."
fi

exit 0
