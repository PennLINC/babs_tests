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
