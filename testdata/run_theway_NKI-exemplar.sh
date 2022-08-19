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

xcpd_version_dot="0.1.2"
xcpd_version_dash="0-1-2"
xcpd_docker_path="pennlinc/xcp_d:${xcpd_version_dot}"

toybidsapp_version_dot="0.0.3"
toybidsapp_version_dash="0-0-3"
toybidsapp_docker_path="chenyingzhao/toy_bids_app:${toybidsapp_version_dot}"
# ++++++++++++++++++++++++++++++++++++

# +++++++++++++++++++++++++++++++++++++
# CHANGE FOR EACH RUN:
folder_BIDS="/cbica/projects/RBC/RBC_EXEMPLARS/NKI" 
bidsapp="toybidsapp"    # e.g., qsiprep, fmriprep, xcp (without d!!), toybidsapp
bidsapp_version_dot=${toybidsapp_version_dot}    # e.g., x.x.x
bidsapp_version_dash=${toybidsapp_version_dash}     # e.g., x-x-x
docker_path=${toybidsapp_docker_path}   # e.g., pennbbl/qsiprep:x.x.x
docker_link="docker://${toybidsapp_docker_path}"  # e.g., docker://pennbbl/qsiprep:x.x.x

folder_sif="${folder_root}/software"    # where the container's .sif file is. Sif file in this folder is temporary and will be deleted once the container dataset is created.
msg_container="this is ${bidsapp} container"   # e.g., this is qsiprep container
folder_container="${folder_root}/software/${bidsapp}-container"    # the datalad dataset of the container

if [[ "${bidsapp}" == "xcp"  ]]; then
    # the input BIDS data should be the output of fMRIPrep:
    folder_bids_input="${folder_data4babs_NKI}/fmriprep-multises"
fi
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
datalad create -D "${msg_container}" ${bidsapp}-container    # -D has to be quoted with "", instead of '', and it has to be quoted....


cd ${bidsapp}-container
fn_sif_orig="${folder_sif}/${bidsapp}-${bidsapp_version_dot}.sif"
cmd="datalad containers-add --url ${fn_sif_orig} ${bidsapp}-${bidsapp_version_dash}"
# ^^ this sif file is copied as: `.datalad/environment/${bidsapp}-${bidsapp_version_dash}/image` 

# as the sif file has been copied into `${bidsapp}-container` folder, now we can delete the original sif file:
cmd="rm ${fn_sif_orig}"

# =====================================================================
# Step 3. Preparing the analysis dataset
# =====================================================================
# ref: https://pennlinc.github.io/docs/TheWay/RunningDataLadPipelines/#preparing-the-analysis-dataset

cd ${folder_data4babs_NKI}
# WAIT: better practice than what's below: wget to local computer, make changes (as below), push to `babs_test` repo, then download from github onto cubic (sometimes cannot wget the up-to-date script, then copy the updated one from a repo of `babs_tests` on cubic)
wget https://raw.githubusercontent.com/PennLINC/TheWay/main/scripts/cubic/bootstrap-${bidsapp}-multises.sh
mv bootstrap-${bidsapp}-multises.sh bootstrap-${bidsapp}-multises-data4babs.sh

# Some updates in the bootstrap script:
# 1. change the container version!!! Search in vscode: x.x.x, and x-x-x, and replace
    # for bootstrap on the outputs of another bootstrap, e.g., XCP:
        # also need to change the version of upper BIDS App (e.g., fMRIPrep is upper of XCP)!!
# 2. add `--new-store-ok` when `create-sibling-ria`, if using latest datalad
# for fmriprep, I used the boostrap.sh from ${folder_root}, which I have tuned and made it more robust
# for xcp, I: 
    # updated xcp version; (no need to update fMRIPrep version - the same as I used)
    # add `--new-store-ok`
    # change xcp-abcd --> xcp_d
    # change xcp-0-1-1.zip to xcp-0.1.1.zip to be consistent with fMRIPrep and QSIPrep

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
    # datalad get -n .    # `analysis/input/data` is a subdataset; get the (udpated) metadata of it. 
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

# If the job was run in `comp_space` and failed (i.e., `participant_job.sh` did not finish and did not `rm -rf` the folder):
    # you need to manually delete that job folder in `comp_space`
    # BEFORE DELETING: cd to that folder, check if there is anything you want (e.g., belongs to other BIDS App's output)! OR if it's a current job that's still running...
    # best to run the 3 commands in the end of `participant_job.sh`: `datalad install`, `datalad drop -r`, `git annex dead here`
    # If `rm -rf` gives Permission error, try this first:
    # `chmod -R +w <foldername>`

# Confirming the zip files are there, after jobs are finished (and said it's SUCCESS):
    # way 1: after merging: you can see the list of zip files in `merge_ds` folder
    # way 2: (no need to merge first), and after you cloned `output_ria`:
        # after merging: when `ls`, you can see the list of zip files in the cloned folder
        # you can even `git checkout <branch name>` to see each branch's output file
            # but probably cannot unzip. If you want to unzip it, merge the output first, and no need to git checkout!
        # bottom line: should not checkout branches in the original `output_ria`!!
        # if there is anything updated in the original `output_ria`, update cloned dataset with: `datalad update -s origin --how merge`  # confirm the sibling is called `origin` first!


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
# Also, in `merge_outputs.sh`, might need to modify `gitref=git show-ref master` to `main`: go to `output_ria/<3char>/<fullchar>`, try `git show-ref main` and `git show-ref master` , see which one gives you output
    # if you modified, remember to `datalad save -m "xx" code/merge_outputs.sh`  # change to relative path if needed!

# Run:   # in `analysis` folder:
bash code/merge_outputs.sh

# =====================================================================
# Unzip and see
# =====================================================================

# clone `output_ria`: | should not directly interact with `output_ria`; should clone and see
datalad clone ria+file:///path/to/qsiprep/output_ria#~data qsiprep_outputs

cd qsiprep_outputs
datalad get <zip file name>
datalad unlock <zip file name>
unzip <zip file name>

# after viewing it:
rm -rf <the foldername got from zip file>   # e.g., `toybidsapp`
datalad drop <zip file name>

# =====================================================================
# Step 6. Audit your runs
# ^^ This is step will be deprecated and no need - there is no need to "bootstrap" for audit. Will work on this part in BABS.
# =====================================================================
# This is to check each subj-ses for successful run output, and/or collect some information from it.

# Prepare the audit scripts for qsiprep-multises-audit:
    # bootstrap-fmriprep-multises-audit.sh from TheWay --> bootstrap-qsiprep-multises-audit-data4babs.sh
        # replaced fmriprep --> qsiprep; 
        # did not find fmriprep version number in this bootstrap script
        # also incorporate: TheWay/scripts/cubic/bootstrap-qsiprep-audit.sh, which uses `bootstrap_zip_audit.sh` 
            # `bootstrap_zip_audit.sh` is originally from RBC as a generic file, it is compatible with qsiprep/fmriprep/xcp, but the version of them are hard coded....
            # therefore I have a copy in this `babs_tests` repo, to make it generic to container versions as an input argument
        # other minor changes: changed master to main; add `--new-store-ok`

# get the bootstrap script for AUDIT:
cd ${folder_data4babs_NKI}
wget https://raw.githubusercontent.com/PennLINC/TheWay/main/scripts/cubic/bootstrap-${bidsapp}-multises-audit.sh
# ^^ if there is no existing one on `TheWay`, modify upon existing one.

mv bootstrap-${bidsapp}-multises-audit.sh bootstrap-${bidsapp}-multises-data4babs.sh

# bootstrap!
bash bootstrap-${bidsapp}-multises-audit-data4babs.sh ${folder_data4babs_NKI}/${bidsapp}-multises    # the argument here must be a full path..

# now, in the main folder, aside of `${bidsapp}-multises`, you should see a new folder called `${bidsapp}-multises-audit`. The structure in this folder is analogous to `${bidsapp}-multises`
cd ${bidsapp}-multises-audit/analysis

# TODO in BABS:
# current bootstrap script (for initial bootstrap, for audit) seems does not check if e.g., dwi exists at all for qsiprep-multises... The `qsub_calls.sh` will cover all existing subj and session folders, regardless `dwi` (or `anat` in fmriprep-multises bootstrap script) exists or not...

# Run the audit: (if you don't have anything to change in `participant_job.sh`)
bash code/qsub_calls.sh
# ^^ this is quick.

# After qsub is finished, go to audit's output_ria/<3char>/<fullchar>, and:
git branch -a
# you should see branches of audit jobs

# Merge: (from `analysis` folder)
# cd ../../../analysis    # if you were in `output_ria/<3char>/<fullchar>`
# BEFORE YOU DO: change `master` to `main`....
bash code/merge_outputs.sh
# ^^ this will generate merge_ds/csvs/*.csv - these are audit results.


# Concatenate single row CSVs from jobs into a table:
bash code/concat_outputs.sh
# ^^ this will generate `${bidsapp}-AUDIT.csv` in the `${bidsapp}-multises-audit` folder

# TODO: the concat csv filename should be `${bidsapp}-MULTISES-AUDIT.csv`, but current versions is without MULTISES