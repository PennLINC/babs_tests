#!/bin/bash

# This is to prepare a OSF sibling of DataLad dataset that will be used for BABS's Circle CI testing

# ++++++++++++++++++++++++++++++++++++++++++
# on cubic RBC project:
folder_root="/cbica/projects/RBC/chenying_practice"
folder_data4babs_NKI="${folder_root}/data_for_babs/NKI"

foldername_dataset="fmriprep_outputs_singleSes_zerout_datalad"   # TO change!
osf_title="data4babs_fmriprepOutputs_singleSes"
# ++++++++++++++++++++++++++++++++++++++++++


# =============================================
# Step 0. Set up
# =============================================

# on cubic:
conda activate mydatalad_chenying

# BELOW: only needs to be run once!
# if datalad-osf extension hasn't been installed:
# pip install datalad-osf

## set up the credentials:
# first, generate a personal access token of OSF - see http://docs.datalad.org/projects/osf/en/latest/tutorial/authentication.html
# then:
# datalad osf-credentials

# =============================================
# Step 1. raw BIDS data --> osf
# =============================================
cd $folder_data4babs_NKI
cd $foldername_dataset

datalad create-sibling-osf --title ${osf_title} -s osf \
    --category data --tag reproducibility --public
# ^^ --title <OSF project name>
# ^^ -s <dataset sibling name>

datalad push --to osf

# Test out locally:
# datalad clone osf://<osf_id>
# cd <osf_id>
# ls
# # if there is any updates on osf:
# datalad update -s origin --how merge   # first: check if the sibling's name is `origin`
# # if you want to view the data:
# datalad get xxxx    # otherwise, the data content hasn't been downloaded from osf...

# ================================
# after there is some problems in several files tracked by git-annex
# re-generate the datalad-tracked folder
# and push to osf
# ================================
cd data_multiSes_zerout_datalad    # or `datalad_singleSes_zerout_datalad`
datalad get *
datalad unlock *

cd ..
cp -rl data_multiSes_zerout_datalad/ data_multiSes_zerout_datalad_new/
cd data_multiSes_zerout_datalad_new/
rm -rf .datalad .git .gitattributes

# create datalad dataset:
datalad create -c text2git -d . --force -D "Some description of this dataset"
# ^^ added `-c text2git` on 11/10/22, need to update all the prepared ds...

datalad save -m "add data"
git-annex fsck    # double check
datalad status

# push to osf:
datalad create-sibling-osf --title ${osf_title} -s osf \
    --category data --tag reproducibility --public
# ^^ --title <OSF project name>
# ^^ -s <dataset sibling name>

datalad push --to osf