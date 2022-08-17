#!/bin/bash

# first, cd to the folder containing this bash script (and Dockerfile + toy_command.sh)

version_tag="0.0.2"

# build:
docker build -t chenyingzhao/toy_bids_app:${version_tag} -f Dockerfile_toyBIDSApp .

# test:
input_dir="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/data_hashedID"
mounted_input_dir="/mnt/testdir"
output_dir="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data"
mounted_output_dir="/mnt/outputdir"

participant_label="sub-01"
session_label="ses-A"

docker run --rm -ti -v ${input_dir}:${mounted_input_dir} \
    -v ${output_dir}:${mounted_output_dir} \
    chenyingzhao/toy_bids_app:${version_tag} \
    ${mounted_input_dir} ${mounted_output_dir} participant \
    --participant_label ${participant_label} \
    --session_label ${session_label}

# push to Docker Hub:
docker push chenyingzhao/toy_bids_app:${version_tag}