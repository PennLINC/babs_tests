#!/bin/bash
dir=$1
echo "Counting number of files in directory: ${dir}"

num_files=`find ${dir} -not -path '*/.*' -type f | wc -l`
# ^^: `-not -path '*/.*'` means does not count hidden files and directories; `wc -l` means count the numbers
echo "Indentified ${num_files} in this directory!"