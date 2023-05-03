# Prepare Docker images for testing BABS

## Docker image `babs_tests` used by CircleCI testing of BABS
Available at [`pennlinc` Docker Hub](https://hub.docker.com/r/pennlinc/babs_tests)
* Build and push: [prep_docker_babs_tests.sh](prep_docker_babs_tests.sh)
* Dockerfile: [Dockerfile_babs_tests](Dockerfile_babs_tests)

### Tag logs
* `datalad0.17.2_v5`: copied pre-built `toybidsapp_0.0.7.sif` into the docker image
    * Others are the same with the last veresion

* `datalad0.17.2_v4`: copied pre-built `toybidsapp_0.0.6.sif` into the docker image
    * The sif file was prebuilt on CUBIC cluster, and saved in folder `/cbica/projects/BABS/toybidsapp_for_babs_tests`
    * The sif file was built using command below:
```
toybidsapp_version="0.0.6"
singularity build toybidsapp_${toybidsapp_version}.sif docker://pennlinc/toy_bids_app:${toybidsapp_version}
```


### Deprecated: DataLad only, no singularity installed
Available at [personal Docker Hub](https://hub.docker.com/r/chenyingzhao/datalad)
* Build and push: [prep_docker_datalad.sh](prep_docker_datalad.sh)
* Dockerfile: [Dockerfile_datalad](Dockerfile_datalad)


## Toy BIDS App `toy_bids_app`
### Basic information
* Where is the Docker image: Available at [`pennlinc` Docker Hub](https://hub.docker.com/r/pennlinc/toy_bids_app).
* What it does: to count number of non-hidden files in a subject's directory(or a session's directory, when `--session-label` is specified). 
* How to call it: see `--help`
* What platform: Its Docker image can be run on both amd64 (Linux + probably Mac with Intel chip) and arm64 (Mac with M1 chip)

### Source code:
* Build and push: [prep_toyBIDSApp.sh](prep_toyBIDSApp.sh)
* Dockerfile: [Dockerfile_toyBIDSApp](Dockerfile_toyBIDSApp)
    * using [toy_command.py](toy_command.py)

### LICENSE
See [LICENSE](LICENSE).