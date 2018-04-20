#!/bin/bash

cleanup() {
	echo "" | tee -a "$LOGFILE"
	echo "Cleanup..." | tee -a "$LOGFILE"
	cd "$SOURCEPATH"
	git checkout "$INITIAL_COMMIT"
	if [ "$STASH_CREATED" == "1" ]; then
		git stash pop
	fi
	cd "$BASEDIR"
	echo "Cleanup finished..." | tee -a "$LOGFILE"
}

PRERUNSCRIPT=""
TESTSCRIPTS=()
declare -i NUMBER_OF_TESTS=0
BUILDSCRIPT=""
STARTCOMMIT=""
ENDCOMMIT=""
SOURCEPATH=""
OUTPUTFILE="git_iterate_result.txt"
LOGFILE="LOG.txt"
PREFIX_DIR=""
for i in "$@"
do
case $i in
	-o=*|--output=*)
	OUTPUTFILE="${i#*=}"
	shift # past argument=value
	;;
	--logfile=*)
	LOGFILE="${i#*=}"
	shift # past argument=value
	;;
	-sp=*|--sourcepath=*)
	SOURCEPATH="${i#*=}"
	shift # past argument=value
	;;
	-bs=*|--buildscript=*)
	BUILDSCRIPT="${i#*=}"
	shift # past argument=value
	;;
	-is=*|--initscript=*)
	PRERUNSCRIPT="${i#*=}"
	shift # past argument=value
	;;
	-ts=*|--testscript=*)
	TESTSCRIPTS+=("${i#*=}")
	NUMBER_OF_TESTS=$NUMBER_OF_TESTS+1
	shift # past argument=value
	;;
	-s=*|--startcommit=*)
	STARTCOMMIT="${i#*=}"
	shift # past argument=value
	;;
	-e=*|--endcommit=*)
	ENDCOMMIT="${i#*=}"
	shift # past argument=value
	;;
	-p=*|--prefix=*)
	PREFIX_DIR="${i#*=}"
	shift # past argument=value
	;;
	*)
	# unknown option
	;;
	esac
done

declare -i SHOULD_EXIT=0
if [ "$NUMBER_OF_TESTS" == "0" ]; then
	echo " => No testscripts specified. Give at least one test with --testscript=<script> or -ts=<script>"
	SHOULD_EXIT=1
fi
if [ "$BUILDSCRIPT" == "" ]; then
	echo " => No buildscript specified. Give exactly one test with --buildscript=<script> or -bs=<script>"
	SHOULD_EXIT=1
fi
if [ "$SOURCEPATH" == "" ]; then
	echo " => No sourcepath specified. Set with --sourcepath=</path/to/repo> or -sp=</path/to/repo>"
	SHOULD_EXIT=1

fi
if [ "$STARTCOMMIT" == "" ]; then
	echo " => No starting commit specified. Set with --startcommit=<integer> or -s=<integer>. Will be used for git checkout HEAD~integer"
	SHOULD_EXIT=1
fi
if [ "$ENDCOMMIT" == "" ]; then
	echo " => No end commit specified. Set with --endcommit=<integer> or -e=<integer>. Will be used for git checkout HEAD~integer"
	SHOULD_EXIT=1
fi
if [ $SHOULD_EXIT -eq 1 ]; then
	exit 128
fi

# Just in case user has it the wrong way around
if [ $STARTCOMMIT -gt $ENDCOMMIT ]; then
	swapstore=$STARTCOMMIT
	STARTCOMMIT=$ENDCOMMIT
	ENDCOMMIT=$swapstore
fi

# Get base dir
BASEDIR=$(pwd)
# Get current date
TODAY=$(date +%d%m-%H%M)
# Get initial commit
cd "$SOURCEPATH"
git diff-files --quiet
if [ $? -ne 0 ];then
	STASH_CREATED="1"
	git stash
fi
INITIAL_COMMIT=$(git rev-parse HEAD)
# In case we need to bail
trap cleanup EXIT
INITIAL_COMMIT_MESSAGE=$(git log --oneline -n 1)
git checkout HEAD~"$STARTCOMMIT"
START_COMMIT_MESSAGE=$(git log --oneline -n 1)
START_COMMIT_SHORT=$(git rev-parse --short HEAD)
git checkout "$INITIAL_COMMIT"
git checkout HEAD~"$ENDCOMMIT"
END_COMMIT_MESSAGE=$(git log --oneline -n 1)
END_COMMIT_SHORT=$(git rev-parse --short HEAD)
cd "$BASEDIR"

RESULTDIR="${PREFIX_DIR}Iterate_${START_COMMIT_SHORT}-${END_COMMIT_SHORT}_Date-$TODAY"
mkdir "$RESULTDIR"
OUTPUTFILE="$RESULTDIR/$OUTPUTFILE"
LOGFILE="$RESULTDIR/$LOGFILE"

echo "#------------------------------------------------------------------------------------------------------" | tee "$OUTPUTFILE"
echo "# Git-Iterate > ${RESULTDIR}" | tee "$OUTPUTFILE"
echo "#------------------------------------------------------------------------------------------------------" | tee -a "$OUTPUTFILE"
echo "# Init script = ${PRERUNSCRIPT}" | tee -a "$OUTPUTFILE"
echo "# Buildscript = ${BUILDSCRIPT}" | tee -a "$OUTPUTFILE"
echo "# Sourcepath  = ${SOURCEPATH}" | tee -a "$OUTPUTFILE"
echo "# Source recent commit [HEAD]: ${INITIAL_COMMIT}" | tee -a "$OUTPUTFILE"
echo "# Source recent commit [HEAD]: ${INITIAL_COMMIT_MESSAGE}" | tee -a "$OUTPUTFILE"
echo "# Test start commit HEAD~${STARTCOMMIT}: ${START_COMMIT_MESSAGE}" | tee -a "$OUTPUTFILE"
echo "# Test end commit   HEAD~${ENDCOMMIT}: ${END_COMMIT_MESSAGE}" | tee -a "$OUTPUTFILE"
echo "# From HEAD~${STARTCOMMIT} to HEAD~${ENDCOMMIT} testing following scrips:" | tee -a "$OUTPUTFILE"
#echo ${TESTSCRIPTS[*]}
declare -i COUNTER=2
for script_it in "${TESTSCRIPTS[@]}";do
	echo "#-->Column $COUNTER: $script_it" | tee -a "$OUTPUTFILE"
	COUNTER=$COUNTER+1
done
echo "#------------------------------------------------------------------------------------------------------" | tee -a "$OUTPUTFILE"

echo # newline
read -p "Continue? (y/n)" -n 1 -r
echo # newline
echo "" > current_buildlog.txt
echo "Starting..." | tee "$LOGFILE"
if [[ $REPLY =~ ^[Yy]$ ]]; then

	if [ "$PRERUNSCRIPT" != "" ]; then
		echo "Running init script..." | tee -a "$LOGFILE"
		echo "Script: $PRERUNSCRIPT" | tee -a "$LOGFILE"
		./${PRERUNSCRIPT}
		echo "Init script finished" | tee -a "$LOGFILE"
	else
		echo "No init script specified!" | tee -a "$LOGFILE"
	fi

	echo "Start iterating git repo..." | tee -a "$LOGFILE"
	for x in $(seq "$STARTCOMMIT" 1 "$ENDCOMMIT"); do
		cd "$SOURCEPATH"
		git checkout "$INITIAL_COMMIT"
		git checkout "HEAD~$x"
		CURRENT_COMMIT_MESSAGE=$(git log --oneline -n 1)
		cd "$BASEDIR"
		echo "--------------------------------" | tee -a "$LOGFILE"
		echo "Now at:  $CURRENT_COMMIT_MESSAGE" | tee -a "$LOGFILE"
		echo "Starting building..." | tee -a "$LOGFILE"
		echo "Buildscript: $BUILDSCRIPT" | tee -a "$LOGFILE"
		echo "$(bash -x ./${BUILDSCRIPT})" > tmp_current_buildlog.txt
		echo "--------------------------------" | tee -a "$LOGFILE"

		TESTRESULTS=()
		RESULTSTRING=""
		BUILD_FAILED=$(cat tmp_current_buildlog.txt | grep "\[100%\]")
		rm tmp_current_buildlog.txt
		if [ "$BUILD_FAILED" == "" ]; then
			RESULTSTRING+="BUILD FAILED, "
			echo "Buildscript failed" | tee -a "$LOGFILE"
		else
			RESULTSTRING+="BUILD SUCCESSFUL, "
			echo "Buildscript finished" | tee -a "$LOGFILE"
			for i in "${TESTSCRIPTS[@]}";do
				echo "Starting test..." | tee -a "$LOGFILE"
				echo "Testscript: $i" | tee -a "$LOGFILE"
				retn_value="$(echo $(./${i}))"
				echo "Test finished!" | tee -a "$LOGFILE"
				echo "--------------------------------" | tee -a "$LOGFILE"
				TESTRESULTS+=("$retn_value")
				RESULTSTRING+="$retn_value"
			done
		fi
		RESULTSTRING+="$CURRENT_COMMIT_MESSAGE"
		echo -e "$RESULTSTRING" >> "$OUTPUTFILE"
	done
fi # exit yes/no dialog
echo "exiting..."
exit 0
