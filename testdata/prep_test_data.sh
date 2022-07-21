#!/bin/bash

# cubic RBC

subjid="XXXXXX"   # find ppt that: 1) longitudinal; 2) has anat + func in each session (make sure to check if the images are there too!)


cd /cbica/projects/RBC/temp_chenying/data_for_babs/NKI

datalad create -c yoda NKI_exemplars
cd NKI_exemplars
datalad clone -d . /cbica/projects/RBC/RBC_EXEMPLARS/NKI/ raw_data

cd raw_data
datalad get -n ${subjid}/

# HOWEVER: why the files in this `subjid` still has symlinks, and after copying out, the files are still symlinks??
# ls -lh ${subjid}

# TRY THE OTHER WAY AROUND: FROM INPUT_RIA????


cp -r ${subjid}/ ../../
cd ../..
ls -l