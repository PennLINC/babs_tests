#!/bin/bash

# first, cd to the folder containing this bash script (and Dockerfile + toy_command.py)

version_tag="0.0.6"
version_tag_dash="0-0-6"

# Build:
# first, test building with regular builder: (later we will use multi-architecture builder to build the image and push)
docker build -t pennlinc/toy_bids_app:${version_tag} -f Dockerfile_toyBIDSApp .

# Test:
input_dir="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/data_hashedID"
input_dir_2="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/k9zw2/fmriprep"  # need to unzip a zip file first...
mounted_input_dir="/mnt/testdir"
output_dir="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data"
mounted_output_dir="/mnt/outputdir"

participant_label="sub-01"
session_label="ses-A"

# unzipped input ds:
docker run --rm -ti -v ${input_dir}:${mounted_input_dir} \
    -v ${output_dir}:${mounted_output_dir} \
    pennlinc/toy_bids_app:${version_tag} \
    ${mounted_input_dir} ${mounted_output_dir} participant \
    --participant_label ${participant_label} \
    --session_label ${session_label} \
    --no-zipped -v

    # expect n=21 if with `--session_label`
    # also, check out without `--session_label`: it should count the entire participant's folder
    # expect n=67

# zipped input ds:
docker run --rm -ti -v ${input_dir_2}:${mounted_input_dir} \
    -v ${output_dir}:${mounted_output_dir} \
    pennlinc/toy_bids_app:${version_tag} \
    ${mounted_input_dir} ${mounted_output_dir} participant \
    --participant_label ${participant_label} \
    --zipped -v

    # expect for # files in sub-01_ses-A_fmriprep*.zip: 174

# to compare with:
# find ${test_dir} -not -path '*/.*' ! -type d | wc -l
# ^^: `-not -path '*/.*'` means does not count hidden files and directories; `wc -l` means count the numbers
# ^^: `! -type d` means not to count folders, but files (and symlinks - data tracked by datalad...)

# Push to Docker Hub:
# docker push pennlinc/toy_bids_app:${version_tag}
# ^^ this is for linux system; on Mac M1, we need to use multi-architecture,
# so that docker image built on Mac M1 can be run on other architectures e.g., cubic with amd64

# ref: https://docs.docker.com/desktop/multi-arch/
docker buildx use mybuilder   # use the builder which gives access to the new multi-architecture features. | created by: $ docker buildx create --name mybuilder
docker buildx build --platform linux/amd64,linux/arm64 --push -t pennlinc/toy_bids_app:${version_tag} -f Dockerfile_toyBIDSApp .

# Test on CUBIC cluster using singularity
# first, build singularity image:
cd /cbica/projects/RBC/chenying_practice/software
singularity build toybidsapp-${version_tag}.sif docker://pennlinc/toy_bids_app:${version_tag}

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
    --session_label ${session_label} \
    --no-zipped \
    -v

# also, check out without `--session_label`: it should count the entire participant's folder

# -B means "bind"

# Add to a datalad dataset - local Mac computer:
datalad create -D "Note about the container" toybidsapp-container-docker
cd toybidsapp-container-docker
datalad containers-add --url dhub://pennlinc/toy_bids_app:${version_tag} toybidsapp-${version_tag_dash}
# ^^ note that it should be `dhub` if you want to pull from docker hub and build as docker image instead of singularity image

# Add to a datalad dataset - CUBIC project BABS:
cd ~/data
singularity build toybidsapp-${version_tag}.sif docker://pennlinc/toy_bids_app:${version_tag}
cd toybidsapp-container
datalad containers-add --url /cbica/projects/BABS/data/toybidsapp-${version_tag}.sif toybidsapp-${version_tag_dash}
rm /cbica/projects/BABS/data/toybidsapp-${version_tag}.sif
