#!/bin/bash -l
#SBATCH --mem=25G
#SBATCH --tmp=200G
#SBATCH --time=48:00:00
#SBATCH -p amd2tb,ram256g

set -e -u -x

sub_id=$1

the_date=`date +%Y%m%d_%H%M%S`   # format: YYYYmmdd_HHMMSS
echo "date: ${the_date}"

folder_main_data="/home/faird/zhaoc/data"
folder_main_plain_data=${folder_main_data}/"plain_data"

filename_sif="fmriprep-23.1.3.sif"
fn_sif=${folder_main_data}/${filename_sif}

folder_input_dataset=${folder_main_plain_data}/"HBN_BIDS_plain"

folder_main_output=${folder_main_plain_data}/"fmriprep_anatonly_HBN"
folder_output=${folder_main_output}/"output_"${sub_id}
mkdir -p $folder_output

folder_wkdir=${folder_main_output}/"wkdir_"${sub_id}"_"${the_date}
mkdir -p ${folder_wkdir}


cd /tmp

singularity run --cleanenv \
    -B ${PWD} \
    -B /home/faird/zhaoc/software/TemplateFlow_home:/SGLR/TEMPLATEFLOW_HOME \
	-B /home/faird/zhaoc/software/FreeSurfer/license.txt:/SGLR/FREESURFER_HOME/license.txt \
    --env TEMPLATEFLOW_HOME=/SGLR/TEMPLATEFLOW_HOME \
    ${fn_sif} \
    ${folder_input_dataset} \
    ${folder_output} \
    participant \
    -w ${folder_wkdir} \
    --n_cpus 1 \
    --stop-on-first-crash \
    --fs-license-file /SGLR/FREESURFER_HOME/license.txt \
    --skip-bids-validation \
    --output-spaces MNI152NLin6Asym:res-2 \
    --force-bbr \
    -v -v \
    --anat-only \
    --participant-label "${sub_id}"

# --sloppy \

rm -rf ${folder_wkdir}
