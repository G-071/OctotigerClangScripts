#!/bin/bash

# Checks results - note do not use any variable names from main program...
check_results() {
	# Loop through all result names
	for result_name in "rho" "egas" "sx" "sy" "tau" "primary_core"; do
		# | sed -e 's/^[ \t]*// removes all leading whitespaces
		result_correct="$(cat "$1" | grep "$result_name" | sed -e 's/^[ \t]*//' | sed "s/$result_name//g")"
		result_actual="$(echo "$2" | grep "$result_name" | sed -e 's/^[ \t]*//' | sed "s/$result_name//g")"
		if [ "$result_correct" == "$result_actual" ]; then
			echo "->$result_name correct!" | tee -a LOG.txt
		else
			echo "==->ERROR: $result_name not correct!" | tee -a LOG.txt
			echo "==->Actual: $result_correct" | tee -a LOG.txt
			echo "==->Correct: $result_actual" | tee -a LOG.txt
			errorcount=$errorcount+1
		fi
	done
}

#Check whether all arguments are present
if [ $# -ne 6 ]; then
	echo "USAGE:"
	echo "------"
	echo "Argument 1: scenario file (for example path/to/scenarion/scenario1.txt)"
	echo "            scenario file contains octotiger parameters and expected results"
	echo "Argument 2: Number of HPX threads for first test (for example 1)"
	echo "Argument 3: Stepsize in which the numer of HPX threads is increased each test (for example 1)"
	echo "Argument 4: Number of HPX threads for the last test (for example 64)"
	echo "Argument 5: Path to octotiger executable"
	echo "Argument 6: Number of threads"
	exit 128
fi

# Get base dir
basedir=$(pwd)
# Get current date
today=$(date +%m-%d-%H-%M)

# Get scenario arguments and current commits
octotiger_args="$(cat "$1" | grep 'octotiger_args' | sed 's/octotiger_args: //g')"
cd src/hpx
current_commit_hpx=$(git rev-parse HEAD)
cd "$basedir"
cd src/octotiger/src
current_commit=$(git rev-parse HEAD)
current_commit_message=$(git log --oneline -n 1)
cd "$basedir"

# Create Test folder
result_folder="${current_commit_message}-${1}-t${6}-$today"
result_folder="$(echo "$result_folder" | sed -e 's/[ \t]/-/g')"
mkdir "$result_folder"

# Log configuration
echo "Using scenarion file: $1" | tee "$result_folder/LOG.txt"
echo "Using HPX commit: $current_commit_hpx" | tee -a "$result_folder/LOG.txt"
echo "Using Octotiger commit: $current_commit" | tee -a "$result_folder/LOG.txt"
echo "Octotiger arguments: $octotiger_args" | tee -a "$result_folder/LOG.txt"

# Create result files
cd "$result_folder"
echo "# Octotiger commit: $current_commit " > computation_time_results.txt
echo "# HPX commit: $current_commit_hpx " >> computation_time_results.txt
echo "# Date of run $today" >> computation_time_results.txt
echo "# Measuring computation time" >> computation_time_results.txt
echo "#" >> computation_time_results.txt
echo "#Number HPX threads,All off,m2m on,m2p on,p2p on,p2m on,All on,All on except p2m" >> computation_time_results.txt
echo "# Octotiger commit: $current_commit " > total_time_results.txt
echo "# HPX commit: $current_commit_hpx " >> total_time_results.txt
echo "# Date of run $today" >> total_time_results.txt
echo "# Measuring total time" >> total_time_results.txt
echo "#" >> total_time_results.txt
echo "#Number HPX threads,All off,multipole on,p2p on,p2m on,All on" >> total_time_results.txt
# Save this version of the script for sanity checks later on
cp ../KNL-test.sh used-script-copy.txt
# Save scenario file for sanity check later on
cp "../$1" "$1"

# Need to use declare, otherwise bash assumes it is a string (untyped)
declare -i errorcount=0
# Running tests
echo "" | tee -a LOG.txt
echo "Running all tests..." | tee -a LOG.txt
for i in $(seq "$2" "$3" "$4"); do
	echo "Running test with $i cuda streams and -t$6 threads..." | tee -a LOG.txt
	output1=$("./../$5" -Ihpx.stacks.use_guard_pages=0 "-t$6" $octotiger_args "-Cuda_streams_per_locality=$i" )
	check_results "$1" "$output1"
	# Clean up results
	clean_output_computational="$i,$(echo "$output1" | grep 'Computation' | sed 's/Computation: //g')"
	clean_output_total="$i,$(echo "$output1" | grep 'Total' | sed 's/Total: //g')"
	# Print and save to files >> for appending
	echo "$clean_output_computational" >> "computation_time_results.txt"
	echo "$clean_output_computational" | tee -a LOG.txt
	echo "$clean_output_total" >> "total_time_results.txt"
	echo "$clean_output_total" | tee -a LOG.txt
done

# Show error count and generate warning file if there are any
echo "" | tee -a LOG.txt
echo "All done!" | tee -a LOG.txt
echo "Errorcount: $errorcount" | tee -a LOG.txt
if [ $errorcount -gt 0 ]; then
	touch THERE_HAVE_BEEN_ERROR_IN_THIS_RUN
fi
