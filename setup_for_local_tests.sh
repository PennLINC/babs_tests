#!/bin/bash

# This is to set up necessarities for local tests of BABS

data_root="../data/"

## container datalad dataset
# as installing singularity is complicated on Mac M1, here I instead using docker container....
cd $data_root

datalad create -D "toy BIDS App - docker container" toybidsapp-container-docker
cd toybidsapp-container-docker/
datalad containers-add --url dhub://pennlinc/toy_bids_app:0.0.7 toybidsapp-0-0-7
# ^^ `dhub://`: to run `docker pull`; if it's `docker://`, then this command will call `singularity` to get the container..
# [INFO   ] Saved pennlinc/toy_bids_app:0.0.3 to /Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/toybidsapp-container-docker/.datalad/environments/toybidsapp-0-0-3/image