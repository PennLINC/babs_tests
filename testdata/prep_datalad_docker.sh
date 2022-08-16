#!/bin/bash

# This is to build the docker image of DataLad that's used for Circle CI tests of BABS

# +++++++++++++++++++++++++++++++
datalad_version="0.17.2"
# +++++++++++++++++++++++++++++++

# first, cd to where this bash file locates

# build:
docker build -t chenyingzhao/datalad:${datalad_version} -f Dockerfile_datalad \
    --build-arg datalad_version=${datalad_version} . 

# test:
docker run --rm -ti chenyingzhao/datalad:${datalad_version}
# in the container, try out:
    # $ datalad --version
    # $ git --version
    # $ git-annex
    # $ datalad create -c text2git my-dataset