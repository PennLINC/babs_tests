#!/bin/bash -l

# example use of this script:
#   $ cd xxx  # cd to current path
#   $ bash sbatch_run_bidsapp.sh toybidsapp toy
#   $ bash sbatch_run_bidsapp.sh fmriprep_anatonly fmranat

which_case=$1   # e.g., "toybidsapp", "fmriprep_anatonly"
which_case_short=$2   # e.g., "toy", "fmranat"

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub_id="sub-NDARHL238VL2"
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

folder_logs="${PWD}/logs"   # this folder is listed in `.gitignore`

cmd="sbatch"
cmd+=" --job-name "${which_case_short}"_"${sub_id}
cmd+=" -e "${folder_logs}/${which_case_short}"_${sub_id}.e%A"
cmd+=" -o "${folder_logs}/${which_case_short}"_${sub_id}.o%A"
cmd+=" run_"${which_case}".sh"
cmd+=" "${sub_id}


echo $cmd
$cmd