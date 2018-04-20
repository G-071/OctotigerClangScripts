#!/bin/bash

# Checks results - note do not use any variable names from main program...
check_results() {
        # Loop through all result names
        for result_name in "rho" "egas" "sx" "sy" "tau" "primary_core"; do
                # | sed -e 's/^[ \t]*// removes all leading whitespaces
                result_correct="$(cat "$1" | grep "$result_name" | sed -e 's/^[ \t]*//' | sed "s/$result_name//g")"
                result_actual="$(echo "$2" | grep "$result_name" | sed -e 's/^[ \t]*//' | sed "s/$result_name//g")"
                if [ "$result_correct" != "$result_actual" ]; then
                        errorcount=$errorcount+1
                fi
        done
}

# Get scenario arguments and current commits
octotiger_args="$(cat "$1" | grep 'octotiger_args' | sed 's/octotiger_args: //g')" 
output="$(./build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger $octotiger_args)"
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
declare -i errorcount=0
check_results $1 "$output"
result_string=""
if [ $errorcount -eq 0 ]; then
	result_string+="TESTS PASSED,\t"
else
	result_string+="TESTS FAILED,\t"
fi
result_string+="$running_time s,\t"

# Return result string by printing to stdout
echo "$result_string"
exit 0
