#!/bin/bash

# This is to build the docker image of DataLad that's used for Circle CI tests of BABS

# +++++++++++++++++++++++++++++++
datalad_version="0.17.2"
datalad_osf_version="0.2.3.1"
datalad_container_version="1.1.6"

docker_tag="datalad${datalad_version}_v1"
# +++++++++++++++++++++++++++++++

# first, cd to where this bash file locates

# build:
docker build -t chenyingzhao/datalad:${docker_tag} -f Dockerfile_datalad \
    --build-arg datalad_version=${datalad_version} \
    --build-arg datalad_osf_version=${datalad_osf_version} \
    --build-arg datalad_container_version=${datalad_container_version} . 

# test:
docker run --rm -ti chenyingzhao/datalad:${docker_tag}
# in the container, try out:
    # $ datalad --version
    # $ git --version
    # $ git-annex
    # $ datalad create -c text2git my-dataset
    # $ datalad osf-credentials --version    # datalad-osf's version
    # $ datalad containers-add --version    # datalad-container's version

# push:
# docker push chenyingzhao/datalad:${docker_tag}
# ^^ this is for linux system; on Mac M1, we need to use multi-architecture, 
# so that docker image built on Mac M1 can be run on other architectures e.g., cubic with amd64

# ref: https://docs.docker.com/desktop/multi-arch/
docker buildx use mybuilder   # use the builder which gives access to the new multi-architecture features. | created by: $ docker buildx create --name mybuilder
docker buildx build --platform linux/amd64,linux/arm64 \
    --push -t chenyingzhao/datalad:${docker_tag} -f Dockerfile_datalad \
    --build-arg datalad_version=${datalad_version} \
    --build-arg datalad_osf_version=${datalad_osf_version} \
    --build-arg datalad_container_version=${datalad_container_version} .
