#!/bin/bash

# cubic RBC
# +++++++++++++++++++++++++++++++++++++++++++
folder_from="/cbica/projects/RBC/RBC_EXEMPLARS/NKI/"
folder_to="/cbica/projects/RBC/chenying_practice/data_for_babs/NKI"
my_foldername="raw_bids_exemplars"  # for datalad clone the bids data
bids_hashing="data_hashedID_noDataLad"  # this folder is to run hashing subject ID and session ID. It's not tracked by DataLad
bids_datalad="data_hashedID_bids"   # this folder is a copy of `bids_hashing`, but as it's hashed, it's tracked by DataLad
qsiprep_multises="qsiprep-multises"
fmriprep_multises="fmriprep-multises"

bids_multiSes_zerout="data_multiSes_zerout_datalad"
bids_singleSes_zerout="data_singleSes_zerout_datalad"

# find ppt that: 
# 1. longitudinal; 
# 2. for each session:
    # has anat/T1w
    # has func/valid BOLD files
    # best to have dwi/valid DWI files

subjid="XXXXXX"    # CHANGE HERE!
subjid_hash="YYYYYYY"   # CHANGE HERE! | e.g., sub-01
# +++++++++++++++++++++++++++++++++++++++++++

# =====================================================
# Step 1. Hash subject ID
# =====================================================
# Step 1.1 Copy necessary data out and get ready for hashing
## BELOW: ONLY DO IT ONCE:
cd ${folder_to}
mkdir ${bids_hashing}   # the data with hashed ID will go here

# clone: # because the original folder is NOT an RIA, not to include "ria+file//"....
datalad clone ${folder_from} ${my_foldername}
cd ${my_foldername}

# DO THIS FOR EACH SUBJECT:
# get and unlock the data I need:
datalad get ${subjid}/
datalad unlock ${subjid}/

# copy it out
cd ../${bids_hashing}
cp -r ../${my_foldername}/${subjid}/ ./

# after this, you can `datalad save` and `datalad drop` the data in `my_foldername`

# ---------------------------------------------------------------
# old script:

# # no need to `datalad get`; just directly modify the code
# # directly `datalad run` to make the changes:
# cd ${my_foldername}
# mkdir -p outputs

# ## BELOW: REPEAT FOR EACH PARTICIPANT:
# # cp original data into outputs/:
# cp -r ${subjid}/ outputs/
# datalad save -m "copy original data into outputs/ for ${subjid}"
# -----------------------------------------------------------------

# Step 1.2 Hash subject IDs
# For each subject:
# First, hash the foldername:
mv ${subjid} ${subjid_hash}

# Then, hash the subj ID: replace the files recursively in all folders
cd ${subjid_hash}
for file in `find . -type f`; do mv -v "$file" "${file/${subjid}/${subjid_hash}}"; done

#for file in `find . -type f -name 'abc*.txt'`; do mv -v "$file" "${file/abc/xyz}"; done

# Finally, hash session names: Repeat the following commands for all ses names:
ses_name="ses-xxxx"
ses_name_hash="ses-?"    # ? = A, B, ....
# First go to a subj's folder --> rename the foldername with hashed ses name manually with `mv`
# Then cd to that folder
# Then run:
for file in `find . -type f`; do mv -v "$file" "${file/${ses_name}/${ses_name_hash}}"; done

# ===================================================
# Step 2. Run FAIRly big workflow
# ===================================================
# Step 2.1 Create DataLad dataset:
cd ${folder_to}  # root folder
datalad create -c text2git ${bids_datalad}
cp -r ${bids_hashing}/* ${bids_datalad}
cd ${bids_datalad}
datalad save -m "add bids data"

# Step 2.1.2 Copy the dataset_description.json from the original datalad dataset (forgot to do this previously)
cd ${bids_datalad}
cp ${folder_from}/dataset_description.json ./
datalad save -m "copy dataset_description.json from original datalad dataset"

# The BIDS Apps' bootstraps can be run at the same time (QSIPrep, fMRIPrep; after fMRIPrep: XCP-D)

# Step 2.2 Run fMRIPrep
# Go to `run_theway_NKI-exemplar.sh`

# Step 2.3 Run QSIPrep
# Go to `run_theway_NKI-exemplar.sh`

# ===================================================
# Step 3. Get ready to OSF - multi-ses & single-ses data
# ===================================================
# This is after QSIPrep and fMRIPrep has been run.

# Step 3.1. hard copy the data out, so that the real images are not tracked by datalad
# if it's original bids data:

# needs to clone --> get & unlock first!
cd ${folder_to}
datalad clone ${bids_datalad} ${bids_datalad}_cloned
cd ${bids_datalad}_cloned
datalad get *
datalad unlock *

cd ..
mkdir -p ${bids_multiSes_zerout}
cp -rl ${bids_datalad}_cloned ${bids_multiSes_zerout}/    # I guess not to use `-l` might avoid the problem of also copying out those .git and .datalad
cd ${bids_multiSes_zerout}
rm -rf .datalad .git .gitattributes   # ah, these were copied too..

# if it's BIDS App derivatives (e.g, from QSIPrep):
# first, datalad clone the output_ria
# then, copy out the zipped data
# then, unzip & delete the zip files

# Step 3.3. Remove identifiable info
# Step 3.3.1 zero-out the images using AFNI `3dcalc`
list_niigz=$(find . -name *.nii.gz)
# e.g., fn="outputs/sub-A00082942/ses-BAS1/anat/sub-A00082942_ses-BAS1_T1w.nii.gz"
for fn in ${list_niigz}
do
    echo $fn
    # using datalad run:
    # example: datalad run -i myimg.nii.gz -o myimg.nii.gz --explicit -m "zero out this image" "3dcalc -a myimg.nii.gz -prefix myimg.nii.gz -overwrite -expr 'a*0'"
    # example: datalad run -i ${fn} -o ${fn} --explicit -m "zero out image ${fn}" "3dcalc -a ${fn} -prefix ${fn} -overwrite -expr 'a*0'"

    # not to use datalad run:
    3dcalc -a ${fn} -prefix ${fn} -overwrite -expr 'a*0'
    echo ""
done

# ^^ this will take a while; 
# after this is done, check the folder size - should be very minimal
    # check: each session folder: several MB at most
        # each .nii.gz should be x*100 KB (T1w images: ~100KB; bold images: ~300-600KB)
    # then check the total size of the entire folder: should be ~ a couple of MB

# Step 3.3.2 Change the `dataset_description.json`!
# VIM `dataset_description.json` AND CHANGE THE FIELD "Name" to "test_data_for_babs"

# Step 3.4. make a copy: to be used for cross-sectional data
cd ${folder_to}
cp -r ${bids_multiSes_zerout}/ ${bids_singleSes_zerout}
# remove the sessions other than one session; remove the foldername of the session to keep
    # sub-01: keep ses-A
    # sub-02: keep ses-B (as it has all anat, dwi, and func)

# Step 3.5. create a datalad dataset
foldername_dataset="??????"  # foldername of: the multi-/single-ses, raw bids/qsiprep/fmriprep folder, read to be datalad dataset
cd $foldername_dataset
datalad create -d . --force -D "Some description of this dataset"
datalad save -m "adding xxxxx data"   # otherwise the data in this folder are untracked...
datalad status      # make sure there is nothing more the save!

# Step 3.6. osf: create osf sibling + push to osf, using the complicated command
# see `osf_siblings.sh`
# osf links: see `README.txt` in this folder

# Step 3.7. You can remove the cloned datalad dataset
cd ${folder_to}
datalad remove -d ${bids_datalad}_cloned