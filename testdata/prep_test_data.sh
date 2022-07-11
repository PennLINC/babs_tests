#!/bin/bash
# This file is to prepare test data for BABS's CircleCI tests
# Data is from RBC study



subjid="xxxxx"   # I need TWO SUBJECTS!    #: Q: CAN WE INCLUDE RBC'S SUBJECT ID ON GITHUB?
folder_main_mine="/cbica/projects/RBC/temp_chenying"
cd ${folder_main_mine}
### BELOW IS MY TEMPORARY SCRIPT FOR GETTING THIS SUBJECT'S DATA:

## raw data:  # see slack pennlinc_dmri on 3/9
folder_raw="~/RBC_RAWDATA/bidsdatasets"
folder_data=${folder_raw}/XXXXXXXXX
cmd="cp -rl ${folder_data}"


## QSIPrep output:
ria_qsiprep="ria+file:///cbica/projects/RBC/production/PNC/qsiprep/output_ria#~data"
foldername_mine="qsiprep_outputs"
# datalad clone:
cmd="datalad clone ${ria_qsiprep} ${foldername_mine}" # there should be a clone in folder `qsiprep_outputs`
echo $cmd

# datalad get:
cd ${foldername_mine}
cmd="datalad get ${foldername_mine}/sub-${subjid}_qsiprep-0.13.1.zip"
echo $cmd

## fMRIPrep output:
ria_fmriprep="ria+file:///cbica/projects/RBC/production/PNC/fmriprep/output_ria#~data"
foldername_mine="fmriprep_outputs"
# datalad clone:
cd ..
cmd="datalad clone ${ria_qsiprep} ${foldername_mine}" # there should be a clone in folder `fmriprep_outputs`
echo $cmd

# datalad get:
cd ${foldername_mine}
cmd="datalad get ???????????"
echo $cmd