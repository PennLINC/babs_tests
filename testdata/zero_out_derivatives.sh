#!/bin/bash

# This is to prepare BIDS App derivatives for testing BABS
# key steps: clone, copy out, unzip, zero-out images, zip again, create datalad dataset and push to OSF

# cubic RBC
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
folder_to="/cbica/projects/RBC/chenying_practice/data_for_babs/NKI"
bidsapp="fmriprep"
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
# can also `datalad drop *.zip` in the ${clone_foldername} folder!

# Step 3.2. Unzip and delete the zip files
list_zipfiles=`ls *.zip`
# below is the version for qsiprep:
if [[ "${bidsapp}" == "qsiprep"  ]]; then
    for zipfile in $list_zipfiles
    do
        echo $zipfile
        filename_itself="${zipfile%.*}"
        unzip $zipfile
        mv $bidsapp $filename_itself
        # remove the $zipfile:
        rm $zipfile

    done
elif [[ "${bidsapp}" == "fmriprep"  ]]; then
    declare -a fmriprep_list_folders=("fmriprep" "freesurfer")  # an array
    for foldername in ${fmriprep_list_folders[@]}   # has two zip files
    do
        for zipfile in `ls *${foldername}*.zip`
        do
            echo $zipfile
            filename_itself="${zipfile%.*}"
            unzip -q $zipfile    # quietly
            mv $foldername $filename_itself
            # remove the $zipfile:
            rm $zipfile

        done
    done
fi

# Step 3.3. Remove identifiable info
if [[ "${bidsapp}" == "qsiprep"  ]]; then
    # Step 3.3.1 zero-out the images using AFNI `3dcalc`
    list_niigz=$(find . -name *.nii.gz)
    for fn in ${list_niigz}   # relative path to the file
    do
        echo $fn
        # using datalad run:
        # example: datalad run -i myimg.nii.gz -o myimg.nii.gz --explicit -m "zero out this image" "3dcalc -a myimg.nii.gz -prefix myimg.nii.gz -overwrite -expr 'a*0'"
        # example: datalad run -i ${fn} -o ${fn} --explicit -m "zero out image ${fn}" "3dcalc -a ${fn} -prefix ${fn} -overwrite -expr 'a*0'"

        # not to use datalad run:
        3dcalc -a ${fn} -prefix ${fn} -overwrite -expr 'a*0'
        echo ""
    done

    # Step 3.3.2 replace `figures` folder with empty files
    for folder in `find . -name figures`  # folder `figures`
    do
        cd ${folder_to}/${multiSes_zerout}
        echo $folder
        cd $folder
        list_files_temp=`find . *`
        cd ..    # root dir of `figures`
        mv figures figures_orig
        mkdir figures
        cd figures
        for file_temp in $list_files_temp
        do
            touch $file_temp   # create empty files
        done
        cd ..
        rm -r figures_orig
    done
    cd ${folder_to}/${multiSes_zerout}

    # Step 3.3.3 replace `h5` file with empty files, as each is ~90MB
    for h5_file_temp in `find . -name *.h5`  # *.h5 in all sub
    do
        rm $h5_file_temp
        touch $h5_file_temp   # create an empty one
    done
elif [[ "${bidsapp}" == "fmriprep"  ]]; then
    # for fmriprep outputs: the tsv in `fmriprep` folder and all small files in `freesurfer`
    #   accumute to hundreds of MB per folder, >1GB per session, even after doing steps in QSIPrep (above)
    #   therefore, all files will be replaced with empty file
    for file_temp in `find . -type f`  # all files
    do
        rm $file_temp
        touch $file_temp
        basename_temp=`basename "$file_temp"`
        echo "this is file: ${basename_temp}" > $file_temp  # 'this is file: xxx.xxx'
    done
fi

# Step 3.3.x download and double check!!

# Step 3.4. make a copy: be used for cross-sectional data
cd ${folder_to}
cp -r ${multiSes_zerout}/ ${singleSes_zerout}
     # TODO: fMRIPrep ^^

# --------------------------------------------
# below: run once for 1) multi-ses; 2) single-ses
which_bids_zerout=${multiSes_zerout}  # ++++ CHANGE HERE!
# --------------------------------------------
# Step 3.5 zip
cd ${folder_to}/$which_bids_zerout
if [[ "${bidsapp}" == "qsiprep"  ]]; then
    for folder_temp in `ls -d *`  # bug: will also catch any `*.zip` file..
    do
        folder_temp=${folder_temp::-1}  # remove "/"
        mv $folder_temp $bidsapp
        7z a "${folder_temp}.zip" $bidsapp
        rm -r $bidsapp
    done
elif [[ "${bidsapp}" == "fmriprep"  ]]; then
    for foldername in ${fmriprep_list_folders[@]}    # has two zip files
    do
        echo $foldername
        for folder_temp in `ls -d *${foldername}*`   # bug: will also catch any `*.zip` file..
        do
            echo $folder_temp
            folder_temp=${folder_temp::-1}  # remove "/"
            mv $folder_temp $foldername
            7z a "${folder_temp}.zip" $foldername
            rm -r $foldername
        done
    done
fi
# can use `unzip -l <zipfilename>` to check the list of files/folders
    # in the zipped file without extracting out the files :)


# Step 3.6 create a datalad dataset
datalad create -c text2git -d . --force -D "Some description of this dataset"
# ^^ added `-c text2git` on 11/14/22, to re-run!!!
datalad save -m "adding xxxxx data"   # otherwise the data in this folder are untracked...
datalad status

# Step 3.7 OSF: create osf sibling + push to osf, using the complicated command
# see `osf_siblings.sh`
# osf links: see `README.txt` in this folder