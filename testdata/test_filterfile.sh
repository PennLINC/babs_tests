#!/bin/bash
# This is to test and compare the filterfiles
#   generated by babs vs by existing bootstrap script
# DO NOT OPEN JSON FILE WITH VSCODE! It will change the format
# Instead, use Atom

folder="/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/check_filterfiles"
cd $folder
# here we use fmriprep's

# ---------------------------------------
# by babs
# ---------------------------------------
# download 'ses-B_filter.json' from '/cbica/comp_space/BABS/job-2141141-sub-02-ses-B/ds'
#   from fmriprep
scp <username>@cubic-sattertt:/cbica/comp_space/BABS/job-2141141-sub-02-ses-B/ds/ses-B_filter.json ./

# ---------------------------------------
# by existing bootstrap script
# ---------------------------------------
# from: `babs_tests/testdata/bootstrap-fmriprep-multises-data4babs.sh`:
# run in a folder on cubic (linux system): ++++++++++
filterfile="existingBS_fmriprep_ses-B_filter.json"
sesid="ses-B"

echo "{" > ${filterfile}
echo "'fmap': {'datatype': 'fmap'}," >> ${filterfile}
echo "'bold': {'datatype': 'func', 'session': '$sesid', 'suffix': 'bold'}," >> ${filterfile}
echo "'sbref': {'datatype': 'func', 'session': '$sesid', 'suffix': 'sbref'}," >> ${filterfile}
echo "'flair': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'FLAIR'}," >> ${filterfile}
echo "'t2w': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'T2w'}," >> ${filterfile}
echo "'t1w': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'T1w'}," >> ${filterfile}
echo "'roi': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'roi'}" >> ${filterfile}
echo "}" >> ${filterfile}

# remove ses and get valid json
sed -i "s/'/\"/g" ${filterfile}
sed -i "s/ses-//g" ${filterfile}
# +++++++++++++++++++++++++++++++++++++++++++++++++++++

# download:
scp <username>@cubic-sattertt:/cbica/projects/BABS/data/existingBS_fmriprep_ses-B_filter.json ./


# --------------------------------------------------
# compare
# --------------------------------------------------
diff ses-B_filter.json existingBS_fmriprep_ses-B_filter.json
# ^^ any diff will be printed out

# OR:
vimdiff ses-B_filter.json existingBS_fmriprep_ses-B_filter.json
# ^^ vim, side by side

# 11/10/22: did not find any diff.