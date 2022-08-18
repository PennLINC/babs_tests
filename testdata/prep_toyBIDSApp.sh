#!/bin/bash

# first, cd to the folder containing this bash script (and Dockerfile + toy_command.sh)

version_tag="0.0.2.9000"
version_tag_dash="0-0-2-9000"

# Build:
# first, test building with regular builder: (later we will use multi-architecture builder to build the image and push)
docker build -t chenyingzhao/toy_bids_app:${version_tag} -f Dockerfile_toyBIDSApp .

# Test:
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

# Push to Docker Hub:
# docker push chenyingzhao/toy_bids_app:${version_tag}  
# ^^ this is for linux system; on Mac M1, we need to use multi-architecture, 
# so that docker image built on Mac M1 can be run on other architectures e.g., cubic with amd64

# ref: https://docs.docker.com/desktop/multi-arch/
docker buildx use mybuilder   # use the builder which gives access to the new multi-architecture features. | created by: $ docker buildx create --name mybuilder
docker buildx build --platform linux/amd64,linux/arm64 --push -t chenyingzhao/toy_bids_app:${version_tag} -f Dockerfile_toyBIDSApp .

# Test on cubic cluster using singularity
# first, build singularity image:
cmd="singularity build toybidsapp-${version_tag}.sif docker://chenyingzhao/toy_bids_app:${version_tag}"

# test running:
input_dir="/cbica/projects/RBC/chenying_practice/data_for_babs/NKI/data_hashedID_noDataLad"
output_dir="/cbica/projects/RBC/chenying_practice/data_for_babs/NKI"
folder_sif="/cbica/projects/RBC/chenying_practice/software"
singularity run --cleanenv -B ${PWD}  \
    ${folder_sif}/toybidsapp-${version_tag}.sif \
    $input_dir \
    $output_dir \
    participant \
    --participant-label $participant_label \
    --session_label ${session_label}


# -B means "bind"