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

# Step 4. Run and debug
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


# STATUS:
# first 30 jobs:
    # n=6:  removed from `qsub_jobs_full.sh`
    # n=24: stopped but without error message?
# last 1 job: success, finished on `comp_space`
# 2nd from last: I played, did not run `fmriprep`;

# TODO:
    # change `where` in `participant_job.sh`; also modify cubic request too
    # change `qsub_jobs.sh` for the list of jobs to submit
    # submit n=5, but on `comp_space`
    # before running, make sure to `datalad save` and `datalad push` to both input and output ria!

# BEFORE RUNNING MANY PARTICIPANTS:
# `participant_job.sh`: change back to: cd ${CBICA_TMPDIR}
# delete the last line (already run) from `qsub_calls.sh`


# Step 5. Merge outputs


# Step 6. Audit your runs
# This is to check each subj-ses for successful run output, and/or collect some information from it.

