#!/bin/bash

# cubic RBC
# +++++++++++++++++++++++++++++++++++++++++++
folder_from="/cbica/projects/RBC/RBC_EXEMPLARS/NKI/"
folder_to="/cbica/projects/RBC/chenying_practice/data_for_babs/NKI"
my_foldername="raw_bids_exemplars"
# find ppt that: 
# 1. longitudinal; 
# 2. for each session:
    # has anat/T1w
    # has func/valid BOLD files
    # best to have dwi/valid DWI files
subjid_1="sub-A00028352"
subjid_2="sub-A00052165"

subjid=${subjid_2}    # CHANGE HERE!
# +++++++++++++++++++++++++++++++++++++++++++

## BELOW: ONLY DO IT ONCE:
cd ${folder_to}

# clone: # because the original folder is NOT an RIA, not to include "ria+file//"....
datalad clone ${folder_from} ${my_foldername}

# no need to `datalad get`; just directly modify the code

# directly `datalad run` to make the changes:
cd ${my_foldername}
mkdir -p outputs

## BELOW: REPEAT FOR EACH PARTICIPANT:
# cp original data into outputs/:
cp -r ${subjid}/ outputs/
datalad save -m "copy original data into outputs/ for ${subjid}"

# zero-out using AFNI `3dcalc`
list_niigz=$(find outputs/${subjid}/ -name *.nii.gz)
# e.g., fn="outputs/sub-A00082942/ses-BAS1/anat/sub-A00082942_ses-BAS1_T1w.nii.gz"
for fn in ${list_niigz}
do
    echo $fn
    # example: datalad run -i myimg.nii.gz -o myimg.nii.gz --explicit -m "zero out this image" "3dcalc -a myimg.nii.gz -prefix myimg.nii.gz -overwrite -expr 'a*0'"
    datalad run -i ${fn} -o ${fn} --explicit -m "zero out image ${fn}" "3dcalc -a ${fn} -prefix ${fn} -overwrite -expr 'a*0'"
    echo ""
done

