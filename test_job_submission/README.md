## Prepare BABS to test
```
conda activate <env>
cd /path/to/babs/repo
pip -q install -e .   # quietly install BABS
```

## Prepare BABS project
* if needed, remove finished jobs:
    1. delete the branch in output RIA: `git branch -D <branch_name>`
    1. reset that job's line in `job_status.csv`
* check if `job_status.csv` reflects the scenario you want.

## SGE
### Simple tests
* simple test: `qsub test.sh 5`  # sleep for 5 sec
* want to keep in the state of `r`: `qsub test.sh 3600`    # sleep for 1h
* want to keep in the state of `qw`: `qsub -l h_vmem=200G test.sh 5`
    * or also try requesting more cpus

After submitting the job, you can open a python console (type `python` in terminal) to test out:
```{python console}
from qstat import qstat  # https://github.com/relleums/qstat
import pandas as pd
```

### Test on real BIDS Apps:
Use real data + real BIDS App (e.g., QSIPrep --sloppy mode)
* This will take a while, so suitable to test out `r`
* `qw`: might consider requesting more resources by changing `participant_job.sh`. 
    * But remember to `datalad save`, `datalad push --to input`, `datalad push --to output`

## Slurm
TO ADD
