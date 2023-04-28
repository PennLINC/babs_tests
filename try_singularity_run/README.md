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
```console
$ apptainer run toyenv.sif
Hello
```

Set up the same env var on host:
```console
$ export MYVAR="Something New!"
$ echo $MYVAR
Something New
```

If injecting host env var into container:
```console
$ apptainer run --env "MYVAR=$MYVAR" toyenv.sif
Something New
```

This should still work with `--cleanenv`:
(ref: [here](https://apptainer.org/docs/user/1.1/environment_and_metadata.html#environment-variable-precedence))
```console
$ apptainer run --cleanenv --env "MYVAR=$MYVAR" toyenv.sif
Something New
```

This also applies to `singularity run`, even if apptainer version was installed for singularity:
```console
$ singularity run --cleanenv --env "MYVAR=$MYVAR" toyenv.sif
Something New
```

Try if previous `export SINGULARITYENV_*` still works on new `apptainer`:
```console
$ export SINGULARITYENV_MYVAR="Something New"
$ singularity run --cleanenv toyenv.sif
INFO:    Environment variable SINGULARITY_TMPDIR is set, but APPTAINER_TMPDIR is preferred
INFO:    Environment variable SINGULARITYENV_MYVAR is set, but APPTAINERENV_MYVAR is preferred
Something New
```
So it's still working, but `APPTAINERENV_*` is preferred

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
```bash
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

```bash
mkdir -p ${PWD}/.git/tmp/wkdir
singularity run --cleanenv \
        -B ${PWD},/path/to/TEMPLATEFLOW_HOME,/path/to/FREESURFER_HOME \
        --env "TEMPLATEFLOW_HOME=$TEMPLATEFLOW_HOME" \
        --env "FREESURFER_HOME=$FREESURFER_HOME" \
        containers/.datalad/environments/fmriprep-20-2-3/image \
        ...
        --fs-license-file /FREESURFER_HOME/license.txt \
```

### New option #3 - Matt suggested; working with freesurfer! But because of my changes it had some flaws for templateflow....
* `/SGLR/TEMPLATEFLOW_HOME`, to make sure it is not consistent with what's defined in the bids app!
    * `SGLR` means singularity, just some name defined by Matt
* In addition, we should not (re-)define env variable `--env FREESURFER_HOME`!
  It will conflict with the internal `FREESURFER_HOME` within the container!

```bash
mkdir -p ${PWD}/.git/tmp/wkdir
singularity run --cleanenv \
	-B ${PWD} \
	-B /cbica/projects/BABS/data/templateflow_home_4test:/SGLR/TEMPLATEFLOW_HOME \
	-B /cbica/projects/BABS/software/FreeSurfer/license.txt:/SGLR/FREESURFER_HOME/license.txt \
	--env TEMPLATEFLOW_HOME=/SGLR/TEMPLATEFLOW_HOME \
	containers/.datalad/environments/fmriprep-20-2-3/image \
    ...
	--fs-license-file /SGLR/FREESURFER_HOME/license.txt \
```
Notes:
* `/cbica/projects/BABS/software/FreeSurfer/license.txt` should be the license.txt registered by the user!
    * This will be added in the container's config YAML file
    * We should not count on `FREESURFER_HOME` on the host - cubic works, but other clusters may not!
    * Better not to use license.txt from cubic's pre-install FreeSurfer! 1) that's a public license; 2) that's a symlink so fmriprep may have error like `path does not exist`.
* Not to include FreeSurfer's stuff as env var in the container
* For `--fs-license-file`, we should use an explicit path

#### Flaw:
Somehow, if using `--env TEMPLATEFLOW_HOME=/SGLR/TEMPLATEFLOW_HOME`, and the host's `$TEMPLATEFLOW_HOME` is empty without downloaded templates, there will be an error from fMRIPrep after several hours (at registratration step): 

```bash
FileNotFoundError: [Errno 2] No such file or directory: '/SGLR/TEMPLATEFLOW_HOME/tpl-MNI152NLin6Asym/tpl-MNI152NLin6Asym_res-02_T1w.nii.gz'
```

How to test `templateflow`? fmriprep with `--output-spaces` specified will use `templateflow`

### New option #4 - really working version:

Finally, i changed back to `export SINGULARITYENV_*`:

```bash
export SINGULARITYENV_TEMPLATEFLOW_HOME=/SGLR/TEMPLATEFLOW_HOME
singularity run --cleanenv \
    -B ${PWD} \
    -B /cbica/projects/BABS/data/templateflow_home_4test:/SGLR/TEMPLATEFLOW_HOME 
    -B /cbica/projects/BABS/software/FreeSurfer/license.txt:/SGLR/FREESURFER_HOME/license.txt \
    containers/.datalad/environments/fmriprep-20-2-3/image \
    ...
    --fs-license-file /SGLR/FREESURFER_HOME/license.txt \
```
