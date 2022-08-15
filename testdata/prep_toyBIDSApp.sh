#!/bin/bash

# first, cd to the folder containing this bash script (and Dockerfile + toy_command.sh)

# build:
docker build -t chenyingzhao/toy_bids_app:0.0.1 -f Dockerfile_toyBIDSApp .

# test:
local_dir="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/data_hashedID/sub-01/ses-A"
mounted_dir="/mnt/testdir"
docker run --rm -ti -v ${local_dir}:${mounted_dir} chenyingzhao/toy_bids_app:0.0.1 ${mounted_dir}

# push to Docker Hub:
docker push chenyingzhao/toy_bids_app:0.0.1