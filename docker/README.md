# Prepare Docker images for testing BABS

## Docker image `babs_tests` used by CircleCI testing of BABS
Available at [`pennlinc` Docker Hub](https://hub.docker.com/r/pennlinc/babs_tests)
* Build and push: [prep_docker_babs_tests.sh](prep_docker_babs_tests.sh)
* Dockerfile: [Dockerfile_babs_tests](Dockerfile_babs_tests)

### Deprecated: DataLad only, no singularity installed
Available at [personal Docker Hub](https://hub.docker.com/r/chenyingzhao/datalad)
* Build and push: [prep_docker_datalad.sh](prep_docker_datalad.sh)
* Dockerfile: [Dockerfile_datalad](Dockerfile_datalad)


## Toy BIDS App `toy_bids_app`
Currently available at [personal Docker Hub](https://hub.docker.com/r/chenyingzhao/toy_bids_app). But will soon be moved to `pennlinc`'s Docker Hub.
* Build and push: [prep_toyBIDSApp.sh](prep_toyBIDSApp.sh)
* Dockerfile: [Dockerfile_toyBIDSApp](Dockerfile_toyBIDSApp)
    * using [toy_command.py](toy_command.py)
