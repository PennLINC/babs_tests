# Create test data for BABS
* where the prepared data is:
    * raw BIDS data in RBC cubic project: `/cbica/projects/RBC/chenying_practice/data_for_babs/NKI`
        * From 2 NKI (longitudinal) subjects (part of the NKI exemplar dataset so QSIPrep, fMRIPrep etc have been tested and successfully finished without error)
            * each has 3 sessions; each session has `fmri`; only one session does not have `dwi`. The used NKI IDs are not saved in this repo (i.e., not public)
        * `raw_bids_exemplars`: this is datalad sibling of original folder: /cbica/projects/RBC/RBC_EXEMPLARS/NKI/. <-- THIS IS MOVED???

    * raw BIDS data below is in BABS cubic project: `/cbica/projects/BABS/data/testdata_NKI/`
        * `data_hashedID_noDataLad`: data with hashed subject ID and session ID; before tracking with DataLad. This was originally prepared in RBC cubic proj, but moved to BABS cubic proj.
        * `data_hashedID_bids`: now tracked by DataLad. As the images are real, this dataset should not be public. It's used to apply real BIDS App (e.g., fMRIPrep) to test out BABS.
        * `data_multiSes_zerout_datalad`: images are zero-out; still multi-ses data. This ds has also been pushed to OSF.
        * `data_singleSes_zerout_datalad`: images are zero-out; only one session per subject was left. This ds has also been pushed to OSF.
    * BIDS data derivatives: in RBC cubic project: `/cbica/projects/RBC/chenying_practice/`
        * `qsiprep*`: apply QSIPrep on the raw BIDS data.
        * `fmriprep*`: apply fMRIPrep on the raw BIDS data.
        * `xcp*`: apply XCP-D on the raw BIDS data.
            * 11/21/22: but seems something wrong? After cloning out output RIA, there is no zipped data?
* Scripts:
    * Overall: [prep_test_data.sh](prep_test_data.sh)
        * when zero-ing the images out, for BIDS data derivatives (e.g., fMRIPrep), this is done in [zero_out_derivatives.sh](zero_out_derivatives.sh), and explained in [zero_out_derivatives.md](zero_out_derivatives.md)
    * The Way part: [run_theway_NKI-exemplar.sh](run_theway_NKI-exemplar.sh)
        * bootstrap scripts: `bootstrap*.sh`, downloaded from `TheWay` GitHub repo; revised by Chenying to make sure run without error.
    * Pushing to OSF: [osf_siblings.sh](osf_siblings.sh)

## Basic information of toy dataset (image zero-ed out, on OSF)
|             | sub-01 | sub-02     |
| :---        |    :----   |          :--- |
| func | ses-A, ses-B, ses-C | ses-A, ses-B, ses-D |
| # of `*_bold.nii.gz` | 6, 6, 6 | 2, 6, 6 |
| dwi | ses-A, ses-B, ses-C | ses-B, ses-D <br>(no ses-A)|
| # of `*_dwi.nii.gz` | 1, 1, 1 | 1, 1 |

#### Number of non-hidden files (ground truth for toy BIDS APP)
single-ses raw BIDS data:
|    | sub-01 | sub-02 |
| :--: | :--: | :--: |
| # of files | 21 | 24 |

multi-ses raw BIDS data:
|   | sub-01 | sub-02 |
| :--: | :--: | :--: |
| ses-A | 21 | 6 |
| ses-B | 23 | 24 |
| ses-C or -D | 23 | 26 |
| Total <br>(without `--session-label`) | 67 | 56 |

single-ses fMRIPrep derivatives:
| which zipped folder  | sub-01 | sub-02 |
| :--: | :--: | :--: |
| freesurfer | 608 | 608 |
| fmriprep | 174 | 174 |

multi-ses fMRIPrep derivatives:
| zipped folder `fmriprep.zip`  | sub-01 | sub-02 |
| :--: | :--: | :--: |
| ses-A | 174 | 90 |
| ses-B | 174 | 174 |
| ses-C or D | 174 | 174 |

How the ground truth is got? Below can be run in Mac or Linux, and can be datalad dataset:
```
find <folder_name> -not -path '*/.*' ! -type d | wc -l
```
* `-not -path '*/.*'` means does not count hidden files and directories; `wc -l` means count the numbers
* `! -type d` means not to count folders, but files (and symlinks - data tracked by datalad...)

## foldername of the toy datalad dataset to be pushed to osf:
|             | multi-ses | single-ses     |
| :---        |    :----   |          :--- |
| raw BIDS      | data_multiSes_zerout_datalad       |  data_singleSes_zerout_datalad  |
| QSIPrep derivatives   | qsiprep_outputs_multiSes_zerout_datalad       | qsiprep_outputs_singleSes_zerout_datalad      |
| fMRIPrep derivatives | fmriprep_outputs_multiSes_zerout_datalad | fmriprep_outputs_singleSes_zerout_datalad |

## OSF links and titles:
|             | multi-ses | single-ses     |
| :---        |    :----:   |          :---: |
| raw BIDS      | https://osf.io/w2nu3/ <br>data4babs_rawBIDS_multiSes | https://osf.io/t8urc/ <br>data4babs_rawBIDS_singleSes |
| QSIPrep derivatives   | https://osf.io/d3js6/<br>data4babs_qsiprepOutputs_multiSes <br> !!  | https://osf.io/8t9sf/<br>data4babs_qsiprepOutputs_singleSes <br> !!  |
| fMRIPrep derivatives | https://osf.io/k9zw2/<br>data4babs_fmriprepOutputs_multiSes <br> !! | https://osf.io/2jvub/<br>data4babs_fmriprepOutputs_singleSes <br> !! |

Others datasets on OSF:
* random files: osf://txsk6

Notes:
* !!: datalad dataset was created without `-c text2git`, so there might be issue when `datalad get` the data!
    * ^^ Above note was added after I added `-c text2git` back in the script. However, above note is probably not up-to-date - it seems I used `-c text2git` in the end: it seems text files e.g., in `w2nu3` are managed by `git` instead of `git-annex` (e.g., when `git-annex fsck sub-01_ses-A_T1w.json`, there is no `fsck <filename> ok`), and I can directly see the content without `datalad get`.
* How to clone: `datalad clone https://osf.io/<id>/ <local_foldername>`
    * make sure you are in a conda env that has datalad-osf installed
    * and, make sure you also set up `datalad osf-credentials` (please provide osf token when asked)
    * path to the dataset can also be: `osf://<id>`
* fMRIPrep derivatives on OSF: all replaced with empty files to save space; this is for toy BIDS App to count the files. For real testing (really running the jobs), need to use real data anyway.
* QSIPrep derivatives on OSF: images are zero-ed out; figures/ and *.h5 files are replaced with empty files


# Create a toy BIDS App to test BABS
* Scripts:
    * [prep_toyBIDSApp.sh](prep_toyBIDSApp.sh)
    * [Dockerfile_toyBIDSApp](Dockerfile_toyBIDSApp)

# Create a Docker image for Circle CI of BABS
This includes DataLad etc.

* Scripts:
    * [prep_datalad_docker.sh](prep_datalad_docker.sh)
    * [Dockerfile_datalad](Dockerfile_datalad)

# Run BIDS Apps
## How long does it take?
* fMRIPrep ingressed Freesurfer
    * i.e., FreeSurfer (in fMRIPrep) has been done, only to run `fMRIPrep`
    * sloppy mode, based on 20.2.3:
        * `--n_cpus 1` in fMRIPrep:   # though "-pe threaded 2"
        * 2.5h for 2 runs in a session
* XCP-D,
    * normal flags, based on 0.3.0:
        * ~30min for 2 runs in a session, `--nthreads 6`
        * 1.5h for 6 runs in a session, did not specify `--nthreads` (i.e., 1 thread)
        * longer if: more runs (bold images), fewer `--nthreads`

# Debug BABS
* check if the filterfile generated by scripts from BABS = generated by existing bootstrap script:
    * [test_filterfile.sh](test_filterfile.sh)

# Practice for learning The Way

* where: /cbica/projects/RBC/chenying_practice
* which dataset: NKI exemplar
* RBC subject ID: the first 30 participants in NKI exemplar

# Move to BABS:
- datalad dataset:
    - if on OSF: can directly delete the dl ds on RBC
    - if not on OSF or cannot be on OSF, better to copy the plain files to BABS, and re-create a datalad dataset there