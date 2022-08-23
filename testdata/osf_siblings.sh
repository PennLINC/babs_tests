#!/bin/bash

# This is to prepare a OSF sibling of DataLad dataset that will be used for BABS's Circle CI testing

# ++++++++++++++++++++++++++++++++++++++++++
# on cubic RBC project:
folder_root="/cbica/projects/RBC/chenying_practice"
folder_data4babs_NKI="${folder_root}/data_for_babs/NKI"

folder_rawBIDS_multises="${folder_data4babs_NKI}/data_hashedID_bids"
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
cd $folder_rawBIDS_multises
# datalad create-sibling-osf --title data4babs_rawBIDS_multises -s osf
# if you're very sure, you can add `--public` to make the OSF project public
# ^^ --title <OSF project name>
# ^^ -s <dataset sibling name>
# https://osf.io/my5b7/   # <- this one failed: when `datalad clone`, the dataset is empty
    # see this issue for more: https://github.com/datalad/datalad-osf/issues/160

datalad create-sibling-osf --title data4babs_testout -s osf2 --category data --tag reproducibility --public
# create-sibling-osf(ok): https://osf.io/fhm8b/

datalad push --to osf2