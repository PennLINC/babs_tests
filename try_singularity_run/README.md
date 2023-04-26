# Try out `singularity run`

Purpose:
* Right now singularity version might be upgraded to `apptainer`
    * Check it out via `singularity --version`
    * if it's `apptainer`, you might see something like: `apptainer version 1.1.7-1.el7`
    * It might also be the reason that we start to see this on cubic:
    ```
    INFO:    Environment variable SINGULARITY_TMPDIR is set, but APPTAINER_TMPDIR is preferred
    ```
* In general old singularity vs new apptainer are similar, but they are different in:
    * Injecting env variable from host into container:
        * old singularity: "using the `--env`, `--env-file` options, or by setting `SINGULARITYENV_` variables outside of the container"
            * ref: [here](https://docs.sylabs.io/guides/3.7/user-guide/environment_and_metadata.html)
        * new apptainer: "using the `--env`, `--env-file` options, or by setting `APPTAINERENV_` variables outside of the container."
            * ref: [here](https://apptainer.org/docs/user/1.1/environment_and_metadata.html#environment-variable-precedence)
        * So setting `*ENV_` variable is different now!
* Other ref:
    * new apptainer, how to bind a path: [here](https://apptainer.org/docs/user/1.1/bind_paths_and_mounts.html)

## Prepare a toy sif image for testing this
* ref: [here](https://apptainer.org/docs/user/1.1/build_a_container.html)
    * Run command below in current folder (not in vscode-server, but regular terminal!):
    ```
    apptainer build toyenv.sif toyenv.def
    ```
* In this toy sif image, there is pre-defined env variable: `export MYVAR="Hello"`. We can overwrite this by injecting env var in host

## Test things out: 
ref: [here](https://apptainer.org/docs/user/1.1/environment_and_metadata.html#environment-variable-precedence)

If not to change anything:
```
$ apptainer run toyenv.sif
Hello
```

Set up the same env var on host:
```
$ export MYVAR="Something New!"
$ echo $MYVAR
Something New
```

If injecting host env var into container:
```
$ apptainer run --env "MYVAR=$MYVAR" toyenv.sif
Something New
```

This should still work with `--cleanenv`:
(ref: [here](https://apptainer.org/docs/user/1.1/environment_and_metadata.html#environment-variable-precedence))
```
$ apptainer run --cleanenv --env "MYVAR=$MYVAR" toyenv.sif
Something New
```

This also applies to `singularity run`, even if apptainer version was installed for singularity:
```
$ singularity run --cleanenv --env "MYVAR=$MYVAR" toyenv.sif
Something New
```

## Expected `singularity run` for FreeSurfer and TemplateFlow
Strategy does not change in BABS:
* By default will handle `TEMPLATEFLOW_HOME`, if ${TEMPLATEFLOW_HOME} env var exists
* if ${FREESURFER_LICENSE} shows up, need to act for FreeSurfer
    * might change this to `${BABS_FREESURFER_LICENSE}`?

### Previous (`babs 0.0.2`):
```
export SINGULARITYENV_TEMPLATEFLOW_HOME=/TEMPLATEFLOW_HOME
mkdir -p ${PWD}/.git/tmp/wkdir
singularity run --cleanenv -B ${PWD},/test/templateflow_home:/TEMPLATEFLOW_HOME \
        containers/.datalad/environments/fmriprep-20-2-3/image \
        ...
        --fs-license-file code/license.txt \
```

### New options
New: use `--env` (which is consistent across old and new version of singularity), instead of `export SINGULARITYENV_*`, as for new version of `singularity`, i.e., `apptainer`, it will use `export APPTAINERENV_*`, i.e., it will be depending on which version of `singularity` installed on the cluster!

### New option #1: (Chenying proposed):
```
mkdir -p ${PWD}/.git/tmp/wkdir
singularity run --cleanenv \
        -B ${PWD},/path/to/TEMPLATEFLOW_HOME:/TEMPLATEFLOW_HOME,/path/to/FREESURFER_HOME:/FREESURFER_HOME \
        --env TEMPLATEFLOW_HOME=/TEMPLATEFLOW_HOME \
        --env FREESURFER_HOME=/FREESURFER_HOME \
        containers/.datalad/environments/fmriprep-20-2-3/image \
        ...
        --fs-license-file /FREESURFER_HOME/license.txt \
```
Here, 
* `/path/to/TEMPLATEFLOW_HOME` is `${TEMPLATEFLOW_HOME}` on host;
* `/path/to/FREESURFER_HOME` is `${FREESURFER_HOME}` on host.

### New option #2 (Chenying proposed): just to bind FS and TemplateFlow same folder as in host (not to define the destination folder):
--> risk:  host's env var path (can vary) overlapped with something in the bids app

```
mkdir -p ${PWD}/.git/tmp/wkdir
singularity run --cleanenv \
        -B ${PWD},/path/to/TEMPLATEFLOW_HOME,/path/to/FREESURFER_HOME \
        --env "TEMPLATEFLOW_HOME=$TEMPLATEFLOW_HOME" \
        --env "FREESURFER_HOME=$FREESURFER_HOME" \
        containers/.datalad/environments/fmriprep-20-2-3/image \
        ...
        --fs-license-file /FREESURFER_HOME/license.txt \
```

### New option #3 - Matt suggested, adopted in the next release after babs 0.0.2 version
`/SGLR/TEMPLATEFLOW_HOME`, to make sure it is not consistent with what's defined in the bids app!
`SGLR` means singularity, just some name defined by Matt

```
mkdir -p ${PWD}/.git/tmp/wkdir
singularity run --cleanenv \
        -B ${PWD} \
        -B /path/to/TEMPLATEFLOW_HOME:/SGLR/TEMPLATEFLOW_HOME \
        -B /path/to/FREESURFER_HOME:/SGLR/FREESURFER_HOME \
        --env TEMPLATEFLOW_HOME=/SGLR/TEMPLATEFLOW_HOME \
        --env FREESURFER_LICENSE=/SGLR/FREESURFER_HOME/license.txt \   # FREESURFER_LICENSE is recognized by fMRIPrep, QSIPrep, and XCP-D. If not recognized by other BIDS Apps, please make a PR. Not to define `FREESURFER_HOME` env var in container is because fmriprep etc bids app might already have that?
        containers/.datalad/environments/fmriprep-20-2-3/image \
        ...
        --fs-license-file ${FREESURFER_LICENSE} \  # using env var name *within* container
```

fmriprep: with `--output-spaces` specified will use `templateflow`

Real output generated by BABS for this option:
```
singularity run --cleanenv \
        -B ${PWD} \
        -B /test/templateflow_home:/SGLR/TEMPLATEFLOW_HOME \
        -B /Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper/data/freesurfer_fake:/SGLR/FREESURFER_HOME \
        --env TEMPLATEFLOW_HOME=/SGLR/TEMPLATEFLOW_HOME \
        --env FREESURFER_LICENSE=/SGLR/FREESURFER_HOME/license.txt \
        containers/.datalad/environments/fmriprep-20-2-3/image \
        ...
        --fs-license-file ${FREESURFER_LICENSE} \
```