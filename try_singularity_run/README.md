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
