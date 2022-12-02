## SGE
* simple test: `qsub test.sh 5`  # sleep for 5 sec
* want to keep in the state of `r`: `qsub test.sh 3600`    # sleep for 1h
* want to keep in the state of `qw`: `qsub -l h_vmem=200G test.sh 5`
    * or also try requesting more cpus

## Slurm
TO ADD
