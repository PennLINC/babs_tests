#!/bin/bash

# build:
docker build -t chenyingzhao/toy_bids_app:0.0.1 -f testdata/Dockerfile_toyBIDSApp .

# test:
docker run --rm chenyingzhao/toy_bids_app:0.0.1 /Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/data_hashedID/sub-01/ses-A

# push to Docker Hub:
docker push chenyingzhao/toy_bids_app:0.0.1