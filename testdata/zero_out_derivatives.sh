#!/bin/bash

# This is to prepare BIDS App derivatives for testing BABS
# key steps: clone, copy out, unzip, zero-out images, zip again, create datalad dataset and push to OSF

# cubic RBC
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
folder_to="/cbica/projects/RBC/chenying_practice/data_for_babs/NKI"
bidsapp="qsiprep"
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

project_foldername="${bidsapp}-multises"
output_ria="${project_foldername}/output_ria"
output_ria_url="ria+file://${folder_to}/${output_ria}#~data"

clone_foldername="${bidsapp}_multises_outputs"
multiSes_zerout="${bidsapp}_outputs_multiSes_zerout_datalad"
singleSes_zerout="${bidsapp}_outputs_singleSes_zerout_datalad"

# Step 3.0. datalad clone of the output ria
cd ${folder_to}
datalad clone ${output_ria_url} ${clone_foldername}

# Step 3.1. hard copy the data out, so that the real images are not tracked by datalad
cd ${clone_foldername}
datalad get *.zip
datalad unlock *.zip

cd ..
mkdir -p ${multiSes_zerout}
cp -r ${clone_foldername}/*.zip ${multiSes_zerout}/
cd ${multiSes_zerout}

# Step 3.2. Unzip and delete the zip files
list_zipfiles=`ls *.zip`
for zipfile in $list_zipfiles
do
    echo $zipfile
    filename_itself="${zipfile%.*}"
    unzip $zipfile
    mv qsiprep $filename_itself
    # remove the $zipfile:
    rm $zipfile
done



# Step 3.4. make a copy: be used for cross-sectional data

# TODO: check out the single-session data done by RBC
# delete "ses-A" from the filename
    # ^^ this step was omitted when preparing raw bids single session data! TO FIX IT!