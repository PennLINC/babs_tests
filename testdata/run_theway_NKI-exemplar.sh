#!/bin/bash

# This is to apply The Way upon NKI-exemplar dataset, to prepare CircleCI test data for BABS. 
# This dataset includes cross-sectional + longitudinal participants.
# Before doing this, make sure that DataLad + datalad_container has been installed.
# Also, you have set up a DataLad dataset as input - see `prep_test_data.sh`.

# Below is done on CUBIC RBC: chenying_practice/ folder

# ++++++++++++++++++++++++++++++++++++
# STABLE PARAMETERS
folder_root="/cbica/projects/RBC/chenying_practice"
folder_data4babs_NKI="${folder_root}/data_for_babs/NKI"
folder_bids_input="${folder_data4babs_NKI}/data_hashedID_bids"   # raw BIDS data as input

fmriprep_version_dot="20.2.3"
fmriprep_version_dash="20-2-3"
fmriprep_docker_path="nipreps/fmriprep:${fmriprep_version_dot}"

qsiprep_version_dot="0.16.0RC3"
qsiprep_version_dash="0-16-0RC3"
qsiprep_docker_path="pennbbl/qsiprep:${qsiprep_version_dot}"

xcpd_version_dot="0.1.1"
xcpd_version_dash="0-1-1"
xcpd_docker_path="pennlinc/xcp_d:${xcpd_version_dot}"
# ++++++++++++++++++++++++++++++++++++

# +++++++++++++++++++++++++++++++++++++
# CHANGE FOR EACH RUN:
folder_BIDS="/cbica/projects/RBC/RBC_EXEMPLARS/NKI" 
bidsapp="qsiprep"    # e.g., qsiprep, fmriprep, xcpd
bidsapp_version_dot=${qsiprep_version_dot}    # e.g., x.x.x
bidsapp_version_dash=${qsiprep_version_dash}     # e.g., x-x-x
docker_path=${qsiprep_docker_path}   # e.g., pennbbl/qsiprep:x.x.x
docker_link="docker://${qsiprep_docker_path}"  # e.g., docker://pennbbl/qsiprep:x.x.x

folder_sif="${folder_root}/software"    # where the container's .sif file is. Sif file in this folder is temporary and will be deleted once the container dataset is created.
msg_container="this is ${bidsapp} container"   # e.g., this is qsiprep container
folder_container="${folder_root}/software/${bidsapp}-container"    # the datalad dataset of the container
# +++++++++++++++++++++++++++++++++++++

# Hint: Run each `cmd` by $cmd. We did not include here just in case you run this bash file

cmd="conda activate mydatalad_chenying"

# =====================================================================
# Step 1. Prepare input datalad dataset - see `prep_test_data.sh`
# =====================================================================

# =====================================================================
# Step 2. Prepare containers
# =====================================================================
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-your-containers
# tips: there is no `docker` command on cubic! So please use `singularity` instead.

cd ${folder_sif}

# Step 2.1 Build singularity
cmd="singularity build ${bidsapp}-${bidsapp_version_dot}.sif ${docker_link}"
# ^^ took how long: ~10-25min; depending on what already exist on the cubic project user.

# Step 2.2 Create a container dataset:
datalad create -D "${msg_container}" ${bidsapp}-container    # -D has to be quoted with "", instead of ''
# next time, try:
# datalad create -D ${msg_container} ${bidsapp}-container 


cd ${bidsapp}-container
fn_sif_orig="${folder_sif}/${bidsapp}-${bidsapp_version_dot}.sif"
cmd="datalad containers-add --url ${fn_sif_orig} ${bidsapp}-${bidsapp_version_dash}"

# as the sif file has been copied into `${bidsapp}-container` folder, now we can delete the original sif file:
cmd="rm ${fn_sif_orig}"

# =====================================================================
# Step 3. Preparing the analysis dataset
# =====================================================================
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-the-analysis-dataset

cd ${folder_data4babs_NKI}
# better practice than what's below: wget to local computer, make changes (as below), push to `babs_test` repo, then download from github onto cubic
wget https://raw.githubusercontent.com/PennLINC/TheWay/main/scripts/cubic/bootstrap-${bidsapp}-multises.sh
mv bootstrap-${bidsapp}-multises.sh bootstrap-${bidsapp}-multises-data4babs.sh

# Some updates in the bootstrap script:
# 1. change the container version!!! Search in vscode: x.x.x, and x-x-x, and replace
# 2. add `--new-store-ok` when `create-sibling-ria`, if using latest datalad
# for fmriprep, I used the boostrap.sh from ${folder_root}, which I have tuned and made it more robust

# Run the bootstrap script:
cmd="bash bootstrap-${bidsapp}-multises-data4babs.sh ${folder_bids_input} ${folder_root}/software/${bidsapp}-container"
# ^^ will create a new folder named `${bidsapp}-multises`

# =====================================================================
# Step 4. Run and debug
# =====================================================================
# Now, follow instructions on pennlinc.github.io to submit the jobs.

# There are three ways to run the jobs:
# 1. auto + at ${CUBIC_TMPDIR} (tmp dir at the compute node): directly submit `qsub_calls.sh`
    # when the job is running, cannot check the temporary data it generates
# 2. auto + at `comp_space`: change the command in `participant_job.sh`--> `datalad save` --> `datald push` to both input & output, before submitting the `qsub_calls.sh`
    # the ephemeral workspace will be at: /cbica/comp_space/<project name>
    # this is good for checking the temporary data while the job is running
    # after the job is successfully finished, the folder will be deleted.
    # However, should not submit a lot of jobs running here! will blow up the space!
# 3. manual/interactive + at `comp_space`: 1) change to `comp_space` as in #2; run the `participant_job.sh` line by line manually to have an idea what's going on at each step
    # make sure to skip `set -e -u -x` in order to not get logged out...

# TODO in BABS:
# current bootstrap script seems does not check if e.g., dwi exists at all for qsiprep-multises... The `qsub_calls.sh` will cover all existing subj and session folders, regardless `dwi` (or `anat` in fmriprep-multises bootstrap script) exists or not...

# If the original input BIDS data (at another folder, not in this bootstrap folder) changes (e.g., a files is added):
    # cd analysis/input/data
    # datalad get -n .    # not sure if this is needed, but suggested by Matt
    # datalad siblings   # get the sibling's name, e.g., `origin`
    # datalad update --how=merge -s <sibling_name>   # get the updates
    # ls    # make sure you really see the updates!!
    # # now, the parent dataset needs to be saved:
    # cd ../..   # now you're at `analysis` folder
    # datalad status    # it will say the `inputs/data` was modified; if not, probably your update wasn't successful...
    # datalad save
    # datalad push --to input
    # datalad push --to output
    # # below is sth Matt did but I did not test out, which is to save the extra inodes
    # datalad uninstall -r --nocheck inputs/data

# Before running, if there is any change (e.g., in participant_job.sh; not needed: qsub_calls.sh): 
    # make sure you:
    # `datalad save`
    # `datalad push --to input`
    # `datalad push --to output`   # if there is already results in output-ria, skip this

# BEFORE RUNNING MANY PARTICIPANTS:
# `participant_job.sh`: change back to: cd ${CBICA_TMPDIR}
# delete the last line (already run) from `qsub_calls.sh`

# RUN!
# [analysis]$ bash code/qsub_calls.sh

# WHAT TO CHECK after the jobs are finished (no jobid in `qstat`):
# 1. check if branches are successfully created:
    # cd to output_ria/<3 char>/<full char>
    # $ git branch -a
# 2. If not all branches are there, you may want to check the log files:
    # cd to analysis/logs
    # then check out the failed jobid's *.e* and *.o*
    # If it's due to missing data for the container, better to remove the job from `qsub_calls.sh`
# 3. If the job failed without error message (probably got killed):
    # on cubic: check out $ qacct -j <jobid> 
    # on cubic: `sge_errors` > my_errors.csv    
    # otherwise, submit a ticket on cubic....


# STATUS for the NK exemplar data I played with (not useful anymore):
# first 30 jobs:
    # n=6:  removed from `qsub_jobs_full.sh`
    # n=24: stopped but without error message?
# last 1 job: success, finished on `comp_space`
# 2nd from last: I played, did not run `fmriprep`;
# 3rd-8st from the last: except one job without data, all done - 2022-7-21




# =====================================================================
# Step 5. Merge outputs
# =====================================================================
# Before running `merge_outputs.sh`, check if you want to delete any branches (a job's outputs) first. 
    # go to `output_ria/<3 char>/<long char>`
    # $ git branch -a
    # if there is a branch you want to delete:
    # $ git branch -d <branch name>

# =====================================================================
# Step 6. Audit your runs
# =====================================================================
# This is to check each subj-ses for successful run output, and/or collect some information from it.

# Done - 2022-08-08