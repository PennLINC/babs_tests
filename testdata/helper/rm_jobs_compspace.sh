#!/bin/bash

# See "README.md" in the same folder for how to prepare `list_rm_jobs_compspace.txt`
# Also see the example file of this in the same folder.

folder_main="/cbica/comp_space/RBC"   # TO CHANGE +++++++++++++++++

cd ${folder_main}

while read foldername; do
    echo "$foldername"

    folder=${folder_main}/${foldername}
    echo $folder
    cd ${folder}/ds

    datalad uninstall -r --nocheck --if-dirty ignore inputs/data
    datalad drop -r . --nocheck
    git annex dead here

    cd ../..
    rm -rf ${foldername}

done </cbica/projects/RBC/chenying_practice/data_for_babs/NKI/list_rm_jobs_compspace.txt

# ^^ TO CHANGE: the path to the file `list_rm_jobs_compspace.txt`
