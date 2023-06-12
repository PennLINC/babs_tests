# Prepare Docker images for testing BABS

There are two Docker images used for testing BABS:
* [toy BIDS App](#toy-bids-app-toy_bids_app)
* [A Docker image used by CircleCI testing of BABS](#docker-image-babs_tests-used-by-circleci-testing-of-babs)
## Toy BIDS App `toy_bids_app`
### Basic information
* Where is the Docker image: Available at [`pennlinc` Docker Hub](https://hub.docker.com/r/pennlinc/toy_bids_app).
* What it does: to count number of non-hidden files in a subject's directory (or a session's directory).
    * Please see below [Detailed explanations](#detailed-explanations) for more.
* How to call it: run `--help`. For example, if you run `docker run` on local computer:
    ```
    docker run --rm -it pennlinc/toy_bids_app:<version_tag> --help
    ```
  and replace `<version_tag>` with the version you'd like to use, e.g., `0.0.7`. It's encouraged to use the latest tagged version available on Docker Hub.
* What platform: Its Docker image can be run on both amd64 (e.g., Linux) and arm64 (Mac with M1 chip)
    *  Mac with Intel chip is probably also fine, but it was not tested.

### Detailed explanations
When using toy BIDS App *together with BABS*, toy BIDS App may behave differently from what you thought. For example, as BABS won't handle `--session-label` flag of toy BIDS App, for raw BIDS dataset, even when it's a multi-session dataset, toy BIDS App counts at subject level (instead of session-level).

The table below shows the level at which toy BIDS App would count non-hidden files, when using *together with BABS*:

| Case for toy BIDS App | single-session dataset | multi-session dataset |
| :-- | :-- | :-- |
| flag `--no-zipped`, for raw BIDS dataset | at subject level | at subject level ⚠️ (although it's multi-ses dataset) |
| flag `zipped`, for zipped BIDS derivatives dataset | at subject level (# of non-hidden files in a subject's zip file) | at session level (# of non-hidden files in a session's zip file) | 

### Source code:
* Build and push: [prep_toyBIDSApp.sh](prep_toyBIDSApp.sh)
* Dockerfile: [Dockerfile_toyBIDSApp](Dockerfile_toyBIDSApp)
    * using [toy_command.py](toy_command.py)

### LICENSE
See [LICENSE](LICENSE).


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


