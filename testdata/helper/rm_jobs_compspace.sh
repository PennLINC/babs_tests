#!/bin/bash

folder_main="/cbica/comp_space/RBC"

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
