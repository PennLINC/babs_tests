#!/bin/bash

# This is to build the docker image used for Circle CI tests of BABS
# Please build it on a Linux machine, but not Mac M1 machine!!!

# +++++++++++++++++++++++++++++++
datalad_version="0.17.2"
datalad_osf_version="0.2.3.1"
datalad_container_version="1.1.6"
toybidsapp_version="0.0.7"

docker_tag="datalad${datalad_version}_v5"
# +++++++++++++++++++++++++++++++

# DO STEP BELOW ON CUBIC USING TRUSTABLE `SINGULARITY` + LINUX SYSTEM!
#   do this on cubic: `/cbica/projects/BABS/toybidsapp_for_babs_tests`
singularity build toybidsapp_${toybidsapp_version}.sif docker://pennlinc/toy_bids_app:${toybidsapp_version}

# Then, download this sif file from cubic to local linux computer
#   and save it to the current folder (as with `Dockerfile`)!


# ON LOCAL LINUX COMPUTER:
# build:
docker build -t pennlinc/babs_tests:${docker_tag} -f Dockerfile_babs_tests \
    --build-arg datalad_version=${datalad_version} \
    --build-arg datalad_osf_version=${datalad_osf_version} \
    --build-arg datalad_container_version=${datalad_container_version} . 

# test:
# docker run --rm -ti pennlinc/babs_tests:${docker_tag}

# push:
# docker push pennlinc/babs_tests:${docker_tag}
# ^^ this is for linux system; 