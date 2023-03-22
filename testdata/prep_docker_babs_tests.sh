#!/bin/bash

# This is to build the docker image used for Circle CI tests of BABS

# +++++++++++++++++++++++++++++++
datalad_version="0.17.2"
datalad_osf_version="0.2.3.1"
datalad_container_version="1.1.6"

docker_tag="datalad${datalad_version}_v2"
# +++++++++++++++++++++++++++++++

# build:
docker build -t pennlinc/babs_tests:${docker_tag} -f Dockerfile_babs_tests \
    --build-arg datalad_version=${datalad_version} \
    --build-arg datalad_osf_version=${datalad_osf_version} \
    --build-arg datalad_container_version=${datalad_container_version} . 

# test:
# docker run --rm -ti pennlinc/babs_tests:${docker_tag}
