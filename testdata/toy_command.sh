#!/bin/bash
testdir=$1   # this `testdir` is the mounted dir in the container; this is probably not the same as the local dir
# echo "Counting number of files in directory: ${testdir}"

# ls ${testdir}
num_files=`find ${testdir} -not -path '*/.*' -type f | wc -l`
# ^^: `-not -path '*/.*'` means does not count hidden files and directories; `wc -l` means count the numbers
echo "Identified ${num_files} non-hidden files in this directory!"