#!/bin/bash

# This is to prepare a OSF sibling of DataLad dataset that will be used for BABS's Circle CI testing

conda activate mydatalad


### Prepare datalad-osf extension:
## install from pypi:
pip install datalad-osf

## set up the credentials:
# first, generate a personal access token of OSF - see http://docs.datalad.org/projects/osf/en/latest/tutorial/authentication.html
# then:
datalad osf-credentials
