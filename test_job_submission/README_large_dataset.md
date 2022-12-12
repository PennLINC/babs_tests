# HBN and FreeSurfer
Purpose: To run fMRIPrep --anat-only (i.e., FreeSurfer) to see the Node error messages from Nipype.
Note: `--anat-only` is also managed by Nipype, so we can see the Node error messages by running so

## About HBN
- HBN is a big dataset (# of subjects: 2600+ in RBC)
- HBN is single-session dataset

Where are the HBN data?
- raw HBN data:
    - `/cbica/projects/RBC/RBC_RAWDATA/bidsdatasets/HBN`
- existing log files (to check Node error from Nipype):
    - `~/production/HBN/fmriprep-anat/analysis/logs` on RBC cubic project
- auditted csv (probably for fmriprep with FS ingressed part, not fmriprep-anat; however still can check out those failed ones)
    - `/cbica/projects/RBC/production/HBN/HBN_group_report.csv`

## Example failed or stalled jobs
### Failed:
Other example job ID in this category:
- to be added...

```
$ tail fpsub-NDARNM147CG2.o9639662

For more details, see the log file /scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds/prep/freesurfer/sub-NDARNM147CG2/scripts/recon-all-lh.log
To report a problem, see http://surfer.nmr.mgh.harvard.edu/fswiki/BugReporting

Standard error:

Return code: 1

220325-21:38:27,398 cli ERROR:
	 Preprocessing did not finish successfully. Errors occurred while processing data from participants: NDARNM147CG2 (1). Check the HTML reports for details.

$ tail fpsub-NDARNM147CG2.e9639662
[INFO] Fetching updates for Dataset(/scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds/pennlinc-containers)
[INFO] == Command start (output follows) =====
+ subid=sub-NDARNM147CG2
+ mkdir -p /scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds/.git/tmp/wdir
+ singularity run --cleanenv -B /scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds pennlinc-containers/.datalad/environments/fmriprep-20-2-3/image inputs/data prep participant -w /scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds/.git/tmp/wkdir --n_cpus 1 --stop-on-first-crash --fs-license-file code/license.txt --skip-bids-validation --output-spaces MNI152NLin6Asym:res-2 --anat-only --participant-label sub-NDARNM147CG2 --force-bbr --cifti-output 91k -v -v
You are using fMRIPrep-20.2.3, and a newer version of fMRIPrep is available: 21.0.1.
Please check out our documentation about how and when to upgrade:
https://fmriprep.readthedocs.io/en/latest/faq.html#upgrading
[INFO] == Command exit (modification check follows) =====
CommandError: 'bash ./code/fmriprep_zip.sh sub-NDARNM147CG2' failed with exitcode 1 under /scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds

# ^^ "CommandError" is sth being detected by audit file

$ qacct -j 9639662 -u rbc
...
qsub_time    Tue Mar 22 13:45:55 2022
start_time   Fri Mar 25 16:18:49 2022
end_time     Fri Mar 25 21:38:27 2022
...
category     -U non-deadlineusers -u rbc -l h_rt=86400,h_stack=256m,h_vmem=25G,tmpfree=200G

```

### Stalled in `autorecon`:
Other example job ID in this category:
- 9638602
- 9639492 of sub-NDARNK826AFY

1. check the output message:
```
tail fpsub-NDARHK598YJC.o9638568

	 resume recon-all : recon-all -autorecon3 -openmp 8 -subjid sub-NDARHK598YJC -sd /scratch/rbc/SGE_9638568/job-9638568-sub-NDARHK598YJC/ds/prep/freesurfer -nosphere -nosurfreg -nojacobian_white -noavgcurv -nocortparc -nopial -noparcstats -nocortparc2 -noparcstats2 -nocortparc3 -noparcstats3 -nopctsurfcon -nocortribbon -nobalabels
220324-13:25:58,689 nipype.workflow INFO:
	 [Node] Running "autorecon3" ("smriprep.interfaces.freesurfer.ReconAll"), a CommandLine Interface with command:
recon-all -autorecon3 -openmp 8 -subjid sub-NDARHK598YJC -sd /scratch/rbc/SGE_9638568/job-9638568-sub-NDARHK598YJC/ds/prep/freesurfer -nosphere -nosurfreg -nojacobian_white -noavgcurv -nocortparc -nopial -noparcstats -nocortparc2 -noparcstats2 -nocortparc3 -noparcstats3 -nopctsurfcon -nocortribbon -nobalabels
220324-13:25:58,691 nipype.interface INFO:
	 resume recon-all : recon-all -autorecon3 -openmp 8 -subjid sub-NDARHK598YJC -sd /scratch/rbc/SGE_9638568/job-9638568-sub-NDARHK598YJC/ds/prep/freesurfer -nosphere -nosurfreg -nojacobian_white -noavgcurv -nocortparc -nopial -noparcstats -nocortparc2 -noparcstats2 -nocortparc3 -noparcstats3 -nopctsurfcon -nocortribbon -nobalabels
220324-13:26:00,599 nipype.workflow INFO:
	 [MultiProc] Running 1 tasks, and 0 jobs ready. Free memory (GB): 164.56/169.56, Free processors: 0/1.
                     Currently running:
                       * fmriprep_wf.single_subject_NDARHK598YJC_wf.anat_preproc_wf.surface_recon_wf.autorecon_resume_wf.autorecon3
```
To understand the workflow code (last line), see [Preprocessing of structural MRI](https://fmriprep.org/en/stable/workflows.html#preprocessing-of-structural-mri), and its subtitle [surface preprocessing](https://fmriprep.org/en/stable/workflows.html#surface-preprocessing): see the graphs

2. check the qacct:
```
qacct -j 9638568 -u rbc
....
qsub_time    Tue Mar 22 13:42:03 2022
start_time   Wed Mar 23 13:33:31 2022
end_time     Thu Mar 24 13:33:32 2022
granted_pe   NONE
slots        1
failed       37  : qmaster enforced h_rt, h_cpu, or h_vmem limit
exit_status  137                  (Killed)
...
category     -U non-deadlineusers -u rbc -l h_rt=86400,h_stack=256m,h_vmem=25G,tmpfree=200G
```

This means that the job has been running for 24h (see `h_rt`) and finally got killed because it reached `h_rt`. So probably stuck in FS.

### Stalled in `_midthickness0`:
```
$ tail fpsub-NDARGL085RTW.o2243509
	 [Job 148] Completed (fmriprep_wf.single_subject_NDARGL085RTW_wf.anat_preproc_wf.anat_derivatives_wf.ds_t1w_fsparc).
221130-08:34:05,868 nipype.workflow INFO:
	 [Node] Setting-up "_midthickness0" in "/scratch/rbc/SGE_2243509/job-2243509-sub-NDARGL085RTW/ds/.git/tmp/wkdir/fmriprep_wf/single_subject_NDARGL085RTW_wf/anat_preproc_wf/surface_recon_wf/gifti_surface_wf/midthickness/mapflow/_midthickness0".
221130-08:34:05,871 nipype.workflow INFO:
	 [Node] Running "_midthickness0" ("niworkflows.interfaces.freesurfer.MakeMidthickness"), a CommandLine Interface with command:
mris_expand -pial /scratch/rbc/SGE_2243509/job-2243509-sub-NDARGL085RTW/ds/.git/tmp/wkdir/fmriprep_wf/single_subject_NDARGL085RTW_wf/anat_preproc_wf/surface_recon_wf/gifti_surface_wf/midthickness/mapflow/_midthickness0/lh.pial -thickness -thickness_name /scratch/rbc/SGE_2243509/job-2243509-sub-NDARGL085RTW/ds/.git/tmp/wkdir/fmriprep_wf/single_subject_NDARGL085RTW_wf/anat_preproc_wf/surface_recon_wf/gifti_surface_wf/midthickness/mapflow/_midthickness0/lh.thickness /scratch/rbc/SGE_2243509/job-2243509-sub-NDARGL085RTW/ds/.git/tmp/wkdir/fmriprep_wf/single_subject_NDARGL085RTW_wf/anat_preproc_wf/surface_recon_wf/gifti_surface_wf/midthickness/mapflow/_midthickness0/lh.smoothwm 0.5 midthickness
221130-08:34:07,102 nipype.workflow INFO:
	 [MultiProc] Running 1 tasks, and 7 jobs ready. Free memory (GB): 339.45/339.65, Free processors: 0/1.
                     Currently running:
                       * _midthickness0

$ qacct -j 2243509 -u rbc
...
qsub_time    Fri Nov 25 20:43:53 2022
start_time   Fri Nov 25 21:19:35 2022
end_time     Wed Nov 30 08:40:20 2022
granted_pe   NONE
slots        1
failed       100 : assumedly after job
exit_status  137                  (Killed)
...
category     -U non-deadlineusers -u rbc -l h_stack=256m,h_vmem=90G,tmpfree=200G
```
So this job was probably stuck and running for 4 days, and someone killed it.