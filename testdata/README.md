# Create test data for BABS
* where the prepared data is: `/cbica/projects/RBC/chenying_practice/data_for_babs/NKI`
    * raw BIDS data:
        * From 2 NKI (longitudinal) subjects (part of the NKI exemplar dataset so QSIPrep, fMRIPrep etc have been tested and successfully finished without error)
            * each has 3 sessions; each session has `fmri`; only one session does not have `dwi`. The used NKI IDs are not saved in this repo (i.e., not public)
        * `raw_bids_exemplars`: this is datalad sibling of original folder: /cbica/projects/RBC/RBC_EXEMPLARS/NKI/
        * `data_hashedID_noDataLad`: data with hashed subject ID and session ID; before tracking with DataLad
        * `data_hashedID_bids`: now tracked by DataLad
        * `data_multiSes_zerout_datalad`: images are zero-out; still multi-ses data
        * `data_singleSes_zerout_datalad`: images are zero-out; only one session per subject was left
    * `qsiprep*`: apply QSIPrep on the raw BIDS data. 
    * `fmriprep*`: apply fMRIPrep on the raw BIDS data.
    * `xcp*`: apply XCP-D on the raw BIDS data.
* Scripts: 
    * Overall: [prep_test_data.sh](prep_test_data.sh)
    * The Way part: [run_theway_NKI-exemplar.sh](run_theway_NKI-exemplar.sh)
        * bootstrap scripts: `bootstrap*.sh`, downloaded from `TheWay` GitHub repo; revised by Chenying to make sure run without error.
    * Pushing to OSF: [osf_siblings.sh](osf_siblings.sh)

## foldername of the toy datalad dataset to be pushed to osf:
|             | multi-ses | single-ses     |
| :---        |    :----   |          :--- |
| raw BIDS      | data_multiSes_zerout_datalad       |  data_singleSes_zerout_datalad  |
| QSIPrep derivatives   | foldername       | foldername      |
| fMRIPrep derivatives | foldername | foldername |

## OSF links:
|             | multi-ses | single-ses     |
| :---        |    :----   |          :--- |
| raw BIDS      | https://osf.io/j854e/       | https://osf.io/zd9a6/   |
| QSIPrep derivatives   | link       | link      |
| fMRIPrep derivatives | link | link |

# Create a toy BIDS App to test BABS
* Scripts:
    * [prep_toyBIDSApp.sh](prep_toyBIDSApp.sh)
    * [Dockerfile_toyBIDSApp](Dockerfile_toyBIDSApp)

# Create a Docker image for Circle CI of BABS
This includes DataLad etc.

* Scripts:
    * [prep_datalad_docker.sh](prep_datalad_docker.sh)
    * [Dockerfile_datalad](Dockerfile_datalad)

# Practice for learning The Way

* where: /cbica/projects/RBC/chenying_practice
* which dataset: NKI exemplar
* RBC subject ID: the first 30 participants in NKI exemplar
