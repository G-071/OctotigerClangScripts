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
declare -i errorcount=0
result_string=""

output="$("./$2" $octotiger_args p2p_kernel_type=old p2m_kernel_type=old m2m_kernel_type=old m2p_kernel_type=old)"
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
check_results "$1" "$output"
if [ $errorcount -eq 0 ]; then
	result_string+="OLD TESTS PASSED, "
else
	result_string+="OLD TESTS FAILED, "
fi
errorcount=0
result_string+="$running_time s,\t"

output=$("./$2" $octotiger_args p2p_kernel_type=old p2m_kernel_type=old m2m_kernel_type=soa_cpu m2p_kernel_type=old)
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
check_results "$1" "$output"
if [ $errorcount -eq 0 ]; then
	result_string+="M2M TESTS PASSED, "
else
	result_string+="M2M TESTS FAILED, "
fi
errorcount=0
result_string+="$running_time s,\t"

output=$("./$2" $octotiger_args p2p_kernel_type=old p2m_kernel_type=old m2m_kernel_type=old m2p_kernel_type=soa_cpu)
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
check_results $1 "$output"
if [ $errorcount -eq 0 ]; then
	result_string+="M2P TESTS PASSED, "
else
	result_string+="M2P TESTS FAILED, "
fi
errorcount=0
result_string+="$running_time s,\t"

output=$("./$2" $octotiger_args p2p_kernel_type=soa_cpu p2m_kernel_type=old m2m_kernel_type=old m2p_kernel_type=old)
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
check_results "$1" "$output"
if [ $errorcount -eq 0 ]; then
	result_string+="P2P TESTS PASSED, "
else
	result_string+="P2P TESTS FAILED, "
fi
errorcount=0
result_string+="$running_time s,\t"

output=$(./$2 $octotiger_args p2p_kernel_type=old p2m_kernel_type=soa_cpu m2m_kernel_type=old m2p_kernel_type=old)
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
check_results "$1" "$output"
if [ $errorcount -eq 0 ]; then
	result_string+="P2M TESTS PASSED, "
else
	result_string+="P2M TESTS FAILED, "
fi
errorcount=0
result_string+="$running_time s,\t"

output=$("./$2" $octotiger_args p2p_kernel_type=soa_cpu p2m_kernel_type=soa_cpu m2m_kernel_type=soa_cpu m2p_kernel_type=soa_cpu)
running_time=$(echo "$output" | grep 'Computation' | sed 's/Computation: //g')
check_results "$1" "$output"
if [ $errorcount -eq 0 ]; then
	result_string+="FULL TESTS PASSED, "
else
	result_string+="FULL TESTS FAILED, "
fi
errorcount=0
result_string+="$running_time s,\t"

# Return result string by printing to stdout
echo "$result_string"
exit 0
