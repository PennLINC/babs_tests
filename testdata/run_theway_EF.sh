#!/bin/bash

# This is to apply The Way upon EF dataset. 
# Before doing this, make sure that DataLad + datalad_container has been installed.

# ++++++++++++++++++++++++++++++++++++
# STABLE PARAMETERS
fmriprep_version_dot="21.0.2"
fmriprep_version_dash="21-0-2"
fmriprep_docker_path="nipreps/fmriprep:${fmriprep_version_dot}"
# ++++++++++++++++++++++++++++++++++++

# +++++++++++++++++++++++++++++++++++++
# CHANGE FOR EACH RUN
folder_BIDS="XXXXXXX" 
bidsapp="fmriprep"    # e.g., qsiprep
bidsapp_version_dot=${fmriprep_version_dot}    # e.g., 0.14.2
bidsapp_version_dash=${fmriprep_version_dash}     # e.g., 0-14-2
docker_path=${fmriprep_docker_path}   # pennbbl/qsiprep:0.14.2
docker_link="docker://${fmriprep_docker_path}"  # e.g., docker://pennbbl/qsiprep:0.14.2

folder_sif="/cbica/projects/EFR01"    # where the container's .sif file is. Sif file in this folder is temporary and will be deleted once the container dataset is created.
msg_container="this is ${bidsapp} container"   # e.g., this is qsiprep container
# +++++++++++++++++++++++++++++++++++++

cmd="conda activate mydatalad"

# Step 1. Create a datalad dataset of the raw BIDS data:
# ref: http://handbook.datalad.org/en/latest/beyond_basics/101-164-dataladdening.html

# BEST TO MAKE A COPY OF THE ORIGINAL DATA.....

cd $folder_BIDS
cmd='datalad create -d . --force -D "raw BIDS data"'  # ref: https://pennlinc.github.io/docs/TheWay/CuratingBIDSonDisk/#testing-pipelines-on-example-subjects
# "--force": enforces dataset creation in non-empty dir
# "-D": description

cmd="datalad save -m 'add input data'"

# Step 2. Prepare containers
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-your-containers
# Step 2.0 Pull docker image:
cd ${folder_sif}
cmd="docker pull ${docker_path}"

# Step 2.1 Build singularity
cmd="singularity build ${bidsapp}-${bidsapp_version_dot}.sif ${docker_link}"

# Step 2.2 Create a container dataset:
cmd="datalad create -D '${msg_container}' ${bidsapp}-container"

cd ${bidsapp}-container
fn_sif_orig="${folder_sif}/${bidsapp}-${bidsapp_version_dash}.sif"
cmd="datalad containers-add --url ${fn_sif_orig} ${bidsapp}-${bidsapp_version_dash}"

# as the sif file has been copied into `${bidsapp}-container` folder, now we can delete the original sif file:
cmd="rm ${fn_sif_orig}"

# Step 3. Preparing the analysis dataset
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-the-analysis-dataset