What to remove/clean before pushing to OSF?

* QSIPrep:
    * zero out images
    * (optional) files in folder `figures`: replace with empty files
    * (optional) `*h5` files: each ~90MB, replace with empty files
* fMRIPrep:
    * all files are replaced with empty files, because accumulated small files lead to >1GB per session data, even after doing steps in QSIPrep (above)

QSIPrep outputs:
```
├── dataset_description.json   # good
├── dwiqc.json
├── logs
│   ├── CITATION.html
│   ├── CITATION.md
│   └── CITATION.tex
├── sub-01
│   ├── anat
│   │   ├── sub-01_desc-brain_mask.nii.gz    # any NIFTI: to zero out
│   │   ├── sub-01_desc-preproc_T1w.nii.gz
│   │   ├── sub-01_dseg.nii.gz
│   │   ├── sub-01_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5   # just transforms... ~90MB. Has been replaced with empty file.
│   │   ├── sub-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5
│   │   ├── sub-01_label-CSF_probseg.nii.gz
│   │   ├── sub-01_label-GM_probseg.nii.gz
│   │   ├── sub-01_label-WM_probseg.nii.gz
│   │   ├── sub-01_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz
│   │   ├── sub-01_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
│   │   ├── sub-01_space-MNI152NLin2009cAsym_dseg.nii.gz
│   │   ├── sub-01_space-MNI152NLin2009cAsym_label-CSF_probseg.nii.gz
│   │   ├── sub-01_space-MNI152NLin2009cAsym_label-GM_probseg.nii.gz
│   │   └── sub-01_space-MNI152NLin2009cAsym_label-WM_probseg.nii.gz
│   ├── figures    # Matt: okay to keep; I: replaced with empty files
│   │   ├── sub-01_seg_brainmask.svg
│   │   ├── sub-01_ses-A_carpetplot.svg
│   │   ├── sub-01_ses-A_coreg.svg
│   │   ├── sub-01_ses-A_desc-resampled_b0ref.svg
│   │   ├── sub-01_ses-A_dwi_denoise_ses_A_dwi_wf_biascorr.svg
│   │   ├── sub-01_ses-A_dwi_denoise_ses_A_dwi_wf_denoising.svg
│   │   ├── sub-01_ses-A_dwi_denoise_ses_A_dwi_wf_unringing.svg
│   │   ├── sub-01_ses-A_sampling_scheme.gif
│   │   └── sub-01_t1_2_mni.svg
│   └── ses-A
│       ├── anat
│       │   └── sub-01_ses-A_from-orig_to-T1w_mode-image_xfm.txt
│       └── dwi
│           ├── sub-01_ses-A_confounds.tsv
│           ├── sub-01_ses-A_desc-ImageQC_dwi.csv
│           ├── sub-01_ses-A_desc-SliceQC_dwi.json
│           ├── sub-01_ses-A_dwiqc.json
│           ├── sub-01_ses-A_space-T1w_desc-brain_mask.nii.gz
│           ├── sub-01_ses-A_space-T1w_desc-eddy_cnr.nii.gz
│           ├── sub-01_ses-A_space-T1w_desc-preproc_dwi.b
│           ├── sub-01_ses-A_space-T1w_desc-preproc_dwi.bval
│           ├── sub-01_ses-A_space-T1w_desc-preproc_dwi.bvec
│           ├── sub-01_ses-A_space-T1w_desc-preproc_dwi.nii.gz
│           └── sub-01_ses-A_space-T1w_dwiref.nii.gz
└── sub-01.html   # no need to delete, as the figures are in `figures` folder
```