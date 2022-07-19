#!/bin/bash

# This is to apply The Way upon NKI-exemplar dataset. 
# This dataset includes cross-sectional + longitudinal participants.
# Before doing this, make sure that DataLad + datalad_container has been installed.

# Below is done on CUBIC RBC: chenying_practice/ folder

# ++++++++++++++++++++++++++++++++++++
# STABLE PARAMETERS
folder_main="/cbica/projects/RBC/chenying_practice"

fmriprep_version_dot="20.2.3"
fmriprep_version_dash="20-2-3"
fmriprep_docker_path="nipreps/fmriprep:${fmriprep_version_dot}"
# ++++++++++++++++++++++++++++++++++++

# +++++++++++++++++++++++++++++++++++++
# CHANGE FOR EACH RUN
folder_BIDS="/cbica/projects/RBC/RBC_EXEMPLARS/NKI" 
bidsapp="fmriprep"    # e.g., qsiprep
bidsapp_version_dot=${fmriprep_version_dot}    # e.g., 0.14.2
bidsapp_version_dash=${fmriprep_version_dash}     # e.g., 0-14-2
docker_path=${fmriprep_docker_path}   # pennbbl/qsiprep:0.14.2
docker_link="docker://${fmriprep_docker_path}"  # e.g., docker://pennbbl/qsiprep:0.14.2

folder_sif="${folder_main}/software"    # where the container's .sif file is. Sif file in this folder is temporary and will be deleted once the container dataset is created.
msg_container="this is ${bidsapp} container"   # e.g., this is qsiprep container
folder_container="${folder_main}/software/${bidsapp}-container"    # the datalad dataset of the container
# +++++++++++++++++++++++++++++++++++++

cmd="conda activate mydatalad"

# SKIPPING STEP 1 HERE - `RBC_EXEMPLAR` is already a datalad dataset
# # Step 1. Create a datalad dataset of the raw BIDS data:
# # ref: http://handbook.datalad.org/en/latest/beyond_basics/101-164-dataladdening.html

# # make a copy of the original input BIDS data:
# folder_orig="/cbica/projects/RBC/RBC_EXEMPLARS/NKI"    # original BIDS data
# cd chenying_practice
# cmd="cp -rl ${folder_orig} ./"   # there is no symlink anymore, but just real data <== SEEMS THIS IS NOT A RECOMMENDED WAY.....
# mv NKI NKI_exemplar_bids   # rename the folder

# # BEST TO MAKE A COPY OF THE ORIGINAL DATA.....

# cd $folder_BIDS
# cmd='datalad create -d . --force -D "raw BIDS data"'  # ref: https://pennlinc.github.io/docs/TheWay/CuratingBIDSonDisk/#testing-pipelines-on-example-subjects
# # "--force": enforces dataset creation in non-empty dir
# # "-D": description

# cmd="datalad save -m 'add input data'"

# Step 2. Prepare containers
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-your-containers
cd ${folder_main}/software

# Q:DO WE NEED THE STEP BELOW??????? CAN WE DIRECTLY USE `SINGULARITY BUILD`?????

# # Step 2.0 Pull as singularity image:  # there is no `docker` command on cubic!
# cd ${folder_sif}
# cmd="singularity pull ${docker_link}"

# Step 2.1 Build singularity
cmd="singularity build ${bidsapp}-${bidsapp_version_dot}.sif ${docker_link}"

# Step 2.2 Create a container dataset:
cmd='datalad create -D "${msg_container}"" ${bidsapp}-container'    # -D has to be quoted with "", instead of ''

cd ${bidsapp}-container
fn_sif_orig="${folder_sif}/${bidsapp}-${bidsapp_version_dot}.sif"
cmd="datalad containers-add --url ${fn_sif_orig} ${bidsapp}-${bidsapp_version_dash}"

# as the sif file has been copied into `${bidsapp}-container` folder, now we can delete the original sif file:
cmd="rm ${fn_sif_orig}"

# Step 3. Preparing the analysis dataset
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-the-analysis-dataset

cd ${folder_main}
cp babs_tests/testdata/bootstrap-fmriprep-multises-NKI-exemplar.sh ./   # copy the bootstrap script

# Run the bootstrap script:
cmd="bash bootstrap-fmriprep-multises-NKI-exemplar.sh /cbica/projects/RBC/RBC_EXEMPLARS/NKI/ ${folder_main}/software/${bidsapp}-container"


# TODO:
#- copy the updated bootstrap.sh back!!!
# BEFORE RUNNING MANY PARTICIPANTS:
# `participant_job.sh`: change back to: cd ${CBICA_TMPDIR}
# delete the last line (already run) from `qsub_calls.sh`