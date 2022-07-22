# Create test data for BABS

* where: /cbica/projects/RBC/chenying_practice/data_for_babs/NKI/raw_bids_exemplars
* which dataset: NKI
* NKI IDs: see [prep_test_data.sh](prep_test_data.sh)
* In this folder:
    * this is a DataLad dataset
    * outputs/: all images' (*.nii.gz) values have been zero-out




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

# Practice for learning The Way

* where: /cbica/projects/RBC/chenying_practice
* which dataset: NKI exemplar
* RBC subject ID: the first 30 participants in NKI exemplar
