# Create test data for BABS

* where: /cbica/projects/RBC/temp_chenying/data_for_babs
* which dataset: HBN
* RBC subject ID:
    * sub-NDARLY030ZBG
    * sub-NDARXD907ZJL
* In this folder:
    * raw BIDS data (not datalad dataset):
        * raw_bids/
    * cloned datalad datasets - commands see [prep_test_data.sh](prep_test_data.sh)
        * qsiprep_outputs/
        * fmriprep-anat_outputs/   # fmriprep anat-only, i.e., freesurfer
    * unzipped qsiprep output:
        * qsiprep/
            * sub-1/
            * sub-2/
        * freesurfer  # fmriprep anat-only
            * sub-1/
            * sub-2/
