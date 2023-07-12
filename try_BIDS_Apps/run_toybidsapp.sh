#!/bin/bash -l
#SBATCH --mem=2G
#SBATCH --tmp=20G
#SBATCH --time=2:00:00
#SBATCH -p k40

set -e -u -x

sub_id=$1

the_date=`date +%Y%m%d_%H%M%S`   # format: YYYYmmdd_HHMMSS
echo "date: ${the_date}"

folder_main_data="/home/faird/zhaoc/data"
folder_main_plain_data=${folder_main_data}/"plain_data"

filename_sif="toybidsapp-0.0.7.sif"
fn_sif=${folder_main_data}/${filename_sif}

folder_input_dataset=${folder_main_plain_data}/"HBN_BIDS_plain"

folder_main_output=${folder_main_plain_data}/"toybidsapp_HBN"
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
    --no-zipped \
	--dummy 2 \
	-v \
	--participant-label "${sub_id}"

rm -rf ${folder_wkdir}
