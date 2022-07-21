#!/bin/bash
# This file is to prepare test data for BABS's CircleCI tests
# Data is from RBC study

# How to choose the subject:
# Make sure the check its raw data dir first - 
# check: HBN's site name is the good one
# check: dwi/ has good data; fmri/ has good data;

# +++++++++++++++++++++++++++++++++++++++++++++
dataset="HBN"

# HBN subject 1, site CBIC
subjid="sub-NDARXD907ZJL"   # HBN subject RBC ID
# HBN subject 2, site RU - I think I should avoid SI (1.5T)
subjid_2="sub-NDARLY030ZBG"

qsiprep_version="0.14.2"
fmriprep_version="20.2.3"
# +++++++++++++++++++++++++++++++++++++++++++++



folder_main_mine="/cbica/projects/RBC/temp_chenying/data_for_babs"
cd ${folder_main_mine}
### BELOW IS MY TEMPORARY SCRIPT FOR GETTING THIS SUBJECT'S DATA:

## raw data:  # see slack pennlinc_dmri on 3/9
mkdir raw_bids
cd raw_bids
folder_raw="/cbica/projects/RBC/RBC_RAWDATA/bidsdatasets/${dataset}"
folder_data=${folder_raw}/${subjid}
cmd="cp -rl ${folder_data}/ ./"

# repeat copying out raw data for the 2nd subject


## QSIPrep output:
cd ..
ria_qsiprep="ria+file:///cbica/projects/RBC/production/${dataset}/qsiprep/output_ria#~data"
foldername_mine="qsiprep_outputs"
# datalad clone:
cmd="datalad clone ${ria_qsiprep} ${foldername_mine}" # there should be a clone in folder `qsiprep_outputs`
echo $cmd

# datalad get:
cd ${foldername_mine}  # why have to cd into the folder???
filename="${subjid}_qsiprep-${qsiprep_version}.zip"
cmd="datalad get ${filename}"
echo $cmd
# copy it out:
cp ${filename} ../
cd ..
ls -l
# (optional) unzip:
unzip -n ${filename} -d .     # `-n` means not to overwrite existing files - needed by the 2nd zipped file

# datalad get - another subject: - repeat above steps!


## fMRIPrep output: # Q: ONLY SEE fmriprep-anat/, instead of fmriprep????
if [[ "${dataset}" == "HBN"   ]]; then
    ria_fmriprep="ria+file:///cbica/projects/RBC/production/${dataset}/fmriprep-anat/output_ria#~data"
else
    ria_fmriprep="ria+file:///cbica/projects/RBC/production/${dataset}/fmriprep/output_ria#~data"
fi
foldername_mine="fmriprep-anat_outputs"
# datalad clone:
cd ..
cmd="datalad clone ${ria_fmriprep} ${foldername_mine}" # there should be a clone in folder `fmriprep-anat_outputs`
echo $cmd


# datalad get:
cd ${foldername_mine}  # why have to cd into the folder???
filename="${subjid}_freesurfer-${fmriprep_version}.zip"
cmd="datalad get ${filename}"
echo $cmd
# copy it out:
cp ${filename} ../
cd ..
ls -l
# (optional) unzip:
unzip -n ${filename} -d .     # `-n` means not to overwrite existing files - needed by the 2nd zipped file

# datalad get - another subject: - repeat above steps!