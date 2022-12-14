# HBN and FreeSurfer
Purpose: To run fMRIPrep --anat-only (i.e., FreeSurfer) to see the Node error messages from Nipype.
Note: `--anat-only` is also managed by Nipype, so we can see the Node error messages by running so

## About HBN
- HBN is a big dataset (# of subjects: 2600+ in RBC)
- HBN is single-session dataset

Where are the HBN data?
- raw HBN data:
    - RBC cubic project: `/cbica/projects/RBC/RBC_RAWDATA/bidsdatasets/HBN`
    - and it's been cloned to BABS cubic projet too:
      - `/cbica/projects/BABS/data/rawdata_HBN`
- existing log files (to check Node error from Nipype):
    - `/cbica/projects/RBC/production/HBN/fmriprep-anat/analysis/logs` on RBC cubic project
- auditted csv (probably for fmriprep with FS ingressed part, not fmriprep-anat; however still can check out those failed ones)
    - `/cbica/projects/RBC/production/HBN/HBN_group_report.csv`

## Example failed or stalled jobs of fMRIPrep --anat-only (FreeSurfer)
There are in total of 3835 `*.o*` files in `fmriprep-anat` folder.

Those with some keywords:
| keywords  | show up in which file | last line of `.o`| last line of `.e` | `qacct`'s `failed` field |  log file counts in `fmriprep-anat` in HBN |
| :-- | :--: | :--: | :--: | :--: | :--: |
| "Exception: No T1w images found for" | in .e | "* Pre-run FreeSurfer's SUBJECTS_DIR: ..." not helpful | "CommandError: 'bash ..." not specific |? | 203 |
| "Cannot allocate memory" | in .o | "Preprocessing did not finish successfully. ..." not specific | "CommandError: 'bash ..." not specific|?| 148 |
| "mris_curvature_stats: Could not open file" | in .o | "Preprocessing did not finish successfully. ..." no specific | "CommandError: 'bash ..." not specific | ?| few | 
| "Numerical result out of range" | in .o | "Preprocessing did not finish successfully. ..." not specific | "CommandError: 'bash ..." not specific | 0 | few |
| "fMRIPrep failed" | in .o | "Preprocessing did not finish successfully. ..." not specific | "CommandError: 'bash ..." not specific|

Without keywords:
| case  | how to detect? | last line of `.o` |
| :--: | :--: | :--: |
| runtime is too long, either exceeding `h_rt` and got killed by cluster | check `qacct` -> field "failed": "37  : qmaster enforced h_rt, h_cpu, or h_vmem limit" | node name in `nipype`, e.g., `* fmriprep_wf. ... .autorecon3` |
| probably killed by the user | check `qacct` --> field "failed": "100 : assumedly after job" | node name in `nipype`, e.g., `* _midthickness0`|

Notes:
- `qacct -o <username> -j <jobid OR jobname>`
	- probably use `-j <jobid>` first, if multiple, check the one with matched `<jobname>`
- `qacct` field `failed`: not necessarily 100% match, but print the code + text in field `failed` would be helpful


### Failed due to `No T1w images found`
1. check `.o` (not helpful):
```
$ tail fpsub-NDARMG405RZK.o2221034
221121-12:15:26,619 cli INFO:
	 Telemetry system to collect crashes and errors is enabled - thanks for your feedback!. Use option ``--notrack`` to opt out.
221121-12:15:52,937 nipype.workflow IMPORTANT:
	 
    Running fMRIPREP version 20.2.3:
      * BIDS dataset path: /scratch/rbc/SGE_2221034/job-2221034-sub-NDARMG405RZK/ds/inputs/data.
      * Participant list: ['NDARMG405RZK'].
      * Run identifier: 20221121-121424_f679e86b-1ac3-4dbd-9cf7-8837c5ab5b72.
      * Output spaces: MNI152NLin6Asym:res-2.
      * Pre-run FreeSurfer's SUBJECTS_DIR: /scratch/rbc/SGE_2221034/job-2221034-sub-NDARMG405RZK/ds/prep/freesurfer.
```

2. check `.e`: found keyword "Exception: No T1w images found for":
```
$ tail fpsub-NDARMG405RZK.e2221034
    self._target(*self._args, **self._kwargs)
  File "/usr/local/miniconda/lib/python3.7/site-packages/fmriprep/cli/workflow.py", line 82, in build_workflow
    retval["workflow"] = init_fmriprep_wf()
  File "/usr/local/miniconda/lib/python3.7/site-packages/fmriprep/workflows/base.py", line 64, in init_fmriprep_wf
    single_subject_wf = init_single_subject_wf(subject_id)
  File "/usr/local/miniconda/lib/python3.7/site-packages/fmriprep/workflows/base.py", line 170, in init_single_subject_wf
    "All workflows require T1w images.".format(subject_id))
Exception: No T1w images found for participant NDARMG405RZK. All workflows require T1w images.
[INFO] == Command exit (modification check follows) ===== 
CommandError: 'bash ./code/fmriprep_zip.sh sub-NDARMG405RZK' failed with exitcode 1 under /scratch/rbc/SGE_2221034/job-2221034-sub-NDARMG405RZK/ds
```

3. check `qacct`: code in `failed` was `0`:
```
$ qacct -j 2221034 -u rbc
...
qsub_time    Mon Nov 21 12:01:52 2022
start_time   Mon Nov 21 12:02:38 2022
end_time     Mon Nov 21 12:15:54 2022
granted_pe   NONE                
slots        1                   
failed       0    
exit_status  1    
...
category     -U non-deadlineusers -u rbc -l h_stack=256m,h_vmem=16G,tmpfree=200G
```

### Failed due to `Cannot allocate memory`:
Other example job ID in this category:
- to be added...

1. check `.o`:
Note: Information in last line is NOT specific! "Cannot allocate memory" actually shows up in #14 line from the bottom.
```
$ tail -15 fpsub-NDARNM147CG2.o9639662
Excessive topologic defect encountered: could not allocate -608163293 edges for retessellation
Cannot allocate memory
Linux 2115fmn043 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

recon-all -s sub-NDARNM147CG2 exited with ERRORS at Fri Mar 25 21:38:25 EDT 2022

For more details, see the log file /scratch/rbc/SGE_9639662/job-9639662-sub-NDARNM147CG2/ds/prep/freesurfer/sub-NDARNM147CG2/scripts/recon-all-lh.log
To report a problem, see http://surfer.nmr.mgh.harvard.edu/fswiki/BugReporting

Standard error:

Return code: 1

220325-21:38:27,398 cli ERROR:
	 Preprocessing did not finish successfully. Errors occurred while processing data from participants: NDARNM147CG2 (1). Check the HTML reports for details.
```

2. Check `.e`: does not contain specific message..
```
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

```
^^ "CommandError" is sth being detected by audit file, however, message is not specific.

3. Check `qacct`:
```
$ qacct -j 9639662 -u rbc
...
qsub_time    Tue Mar 22 13:45:55 2022
start_time   Fri Mar 25 16:18:49 2022
end_time     Fri Mar 25 21:38:27 2022
...
category     -U non-deadlineusers -u rbc -l h_rt=86400,h_stack=256m,h_vmem=25G,tmpfree=200G

```

### Failed in `mris_curvature_stats`:
1. check `.o`: Might be used as keywords "mris_curvature_stats: Could not open file"
```
$ tail -20 fpsub-NDARKA085YRG.o2221072
                 Outputting results using filestem   [ ../stats/lh.curv.stats ]
             Toggling save flag on curvature files                       [ ok ]
                                   Setting surface [ sub-NDARKA085YRG/lh.smoothwm ]
                                Reading surface...                       [ ok ]
mris_curvature_stats: Could not open file '../stats/lh.curv.stats' for appending.

No such file or directory
Linux 211affn007 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

recon-all -s sub-NDARKA085YRG exited with ERRORS at Fri Nov 25 14:28:42 EST 2022

For more details, see the log file /scratch/rbc/SGE_2221072/job-2221072-sub-NDARKA085YRG/ds/prep/freesurfer/sub-NDARKA085YRG/scripts/recon-all-lh.log
To report a problem, see http://surfer.nmr.mgh.harvard.edu/fswiki/BugReporting

Standard error:

Return code: 1

221125-14:28:44,324 cli ERROR:
	 Preprocessing did not finish successfully. Errors occurred while processing data from participants: NDARKA085YRG (1). Check the HTML reports for details.
```
2. check `.e` (not helful):
```
$ tail -10 fpsub-NDARKA085YRG.e2221072
[INFO] Fetching updates for Dataset(/scratch/rbc/SGE_2221072/job-2221072-sub-NDARKA085YRG/ds/pennlinc-containers) 
[INFO] == Command start (output follows) ===== 
+ subid=sub-NDARKA085YRG
+ mkdir -p /scratch/rbc/SGE_2221072/job-2221072-sub-NDARKA085YRG/ds/.git/tmp/wdir
+ singularity run --cleanenv -B /scratch/rbc/SGE_2221072/job-2221072-sub-NDARKA085YRG/ds pennlinc-containers/.datalad/environments/fmriprep-20-2-3/image inputs/data prep participant -w /scratch/rbc/SGE_2221072/job-2221072-sub-NDARKA085YRG/ds/.git/tmp/wkdir --n_cpus 1 --stop-on-first-crash --fs-license-file code/license.txt --skip-bids-validation --output-spaces MNI152NLin6Asym:res-2 --anat-only --participant-label sub-NDARKA085YRG --force-bbr --cifti-output 91k -v -v
You are using fMRIPrep-20.2.3, and a newer version of fMRIPrep is available: 22.0.2.
Please check out our documentation about how and when to upgrade:
https://fmriprep.readthedocs.io/en/latest/faq.html#upgrading
[INFO] == Command exit (modification check follows) ===== 
CommandError: 'bash ./code/fmriprep_zip.sh sub-NDARKA085YRG' failed with exitcode 1 under /scratch/rbc/SGE_2221072/job-2221072-sub-NDARKA085YRG/ds
```

### Failed due to `Numerical result out of range`: (few had this issue)
1. check `.o`: found keyword "Numerical result out of range":
```
$ tail -20 fpsub-NDARNK064DXY.o79780
After retessellation of defect 27 (v0=27418), euler #=-75 (77266,220765,143424) : difference with theory (-112) = -37 

CORRECTING DEFECT 28 (vertices=25886, convex hull=8047, v0=31007)
normal vector of length zero at vertex 93149 with 0 faces
vertex 93149 has 0 face
XL defect detected...
Numerical result out of range
Linux 211affn009 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

recon-all -s sub-NDARNK064DXY exited with ERRORS at Wed Apr  6 06:47:44 EDT 2022

For more details, see the log file /scratch/rbc/SGE_79780/job-79780-sub-NDARNK064DXY/ds/prep/freesurfer/sub-NDARNK064DXY/scripts/recon-all-lh.log
To report a problem, see http://surfer.nmr.mgh.harvard.edu/fswiki/BugReporting

Standard error:

Return code: 1

220406-06:47:45,770 cli ERROR:
	 Preprocessing did not finish successfully. Errors occurred while processing data from participants: NDARNK064DXY (1). Check the HTML reports for details.
```

2. check `.o` file: (not useful):
```
$ tail -10 fpsub-NDARNK064DXY.e79780
[INFO] Fetching updates for Dataset(/scratch/rbc/SGE_79780/job-79780-sub-NDARNK064DXY/ds/pennlinc-containers) 
[INFO] == Command start (output follows) ===== 
+ subid=sub-NDARNK064DXY
+ mkdir -p /scratch/rbc/SGE_79780/job-79780-sub-NDARNK064DXY/ds/.git/tmp/wdir
+ singularity run --cleanenv -B /scratch/rbc/SGE_79780/job-79780-sub-NDARNK064DXY/ds pennlinc-containers/.datalad/environments/fmriprep-20-2-3/image inputs/data prep participant -w /scratch/rbc/SGE_79780/job-79780-sub-NDARNK064DXY/ds/.git/tmp/wkdir --n_cpus 1 --stop-on-first-crash --fs-license-file code/license.txt --skip-bids-validation --output-spaces MNI152NLin6Asym:res-2 --anat-only --participant-label sub-NDARNK064DXY --force-bbr --cifti-output 91k -v -v
You are using fMRIPrep-20.2.3, and a newer version of fMRIPrep is available: 21.0.1.
Please check out our documentation about how and when to upgrade:
https://fmriprep.readthedocs.io/en/latest/faq.html#upgrading
[INFO] == Command exit (modification check follows) ===== 
CommandError: 'bash ./code/fmriprep_zip.sh sub-NDARNK064DXY' failed with exitcode 1 under /scratch/rbc/SGE_79780/job-79780-sub-NDARNK064DXY/ds
```

3. `qacct`: `failed` code is `0`
```
$ qacct -o rbc -j 79780
...
qsub_time    Mon Apr  4 12:08:32 2022
start_time   Mon Apr  4 12:09:36 2022
end_time     Wed Apr  6 06:47:46 2022
granted_pe   NONE                
slots        1                   
failed       0    
exit_status  1  
...
category     -U non-deadlineusers -u rbc -l h_stack=256m,h_vmem=16G,tmpfree=200G
```


### Failed with `fMRIPrep failed`:
1. check `.o`:
```
$ tail -40 fpsub-NDARZZ740MLM.o79892
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/volumeutils.py", line 519, in array_from_file
    infile.seek(offset)
  File "indexed_gzip/indexed_gzip.pyx", line 635, in indexed_gzip.indexed_gzip._IndexedGzipFile.seek
indexed_gzip.indexed_gzip.CrcError: CRC/size validation failed - the GZIP data might be corrupt

220405-07:47:42,749 nipype.workflow CRITICAL:
	 fMRIPrep failed: Traceback (most recent call last):
  File "/usr/local/miniconda/lib/python3.7/site-packages/nipype/pipeline/plugins/multiproc.py", line 67, in run_node
    result["result"] = node.run(updatehash=updatehash)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nipype/pipeline/engine/nodes.py", line 516, in run
    result = self._run_interface(execute=True)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nipype/pipeline/engine/nodes.py", line 635, in _run_interface
    return self._run_command(execute)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nipype/pipeline/engine/nodes.py", line 741, in _run_command
    result = self._interface.run(cwd=outdir)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nipype/interfaces/base/core.py", line 428, in run
    runtime = self._run_interface(runtime)
  File "/usr/local/miniconda/lib/python3.7/site-packages/niworkflows/interfaces/fixes.py", line 48, in _run_interface
    message="%s (niworkflows v%s)" % (self.__class__.__name__, __version__),
  File "/usr/local/miniconda/lib/python3.7/site-packages/niworkflows/interfaces/utils.py", line 239, in _copyxform
    newimg.to_filename(out_image)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/filebasedimages.py", line 333, in to_filename
    self.to_file_map()
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/analyze.py", line 1007, in to_file_map
    data = np.asanyarray(self.dataobj)
  File "/usr/local/miniconda/lib/python3.7/site-packages/numpy/core/numeric.py", line 553, in asanyarray
    return array(a, dtype, copy=False, order=order, subok=True)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/arrayproxy.py", line 391, in __array__
    arr = self._get_scaled(dtype=dtype, slicer=())
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/arrayproxy.py", line 358, in _get_scaled
    scaled = apply_read_scaling(self._get_unscaled(slicer=slicer), scl_slope, scl_inter)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/arrayproxy.py", line 337, in _get_unscaled
    mmap=self._mmap)
  File "/usr/local/miniconda/lib/python3.7/site-packages/nibabel/volumeutils.py", line 519, in array_from_file
    infile.seek(offset)
  File "indexed_gzip/indexed_gzip.pyx", line 635, in indexed_gzip.indexed_gzip._IndexedGzipFile.seek
indexed_gzip.indexed_gzip.CrcError: CRC/size validation failed - the GZIP data might be corrupt

220405-07:47:43,327 cli ERROR:
	 Preprocessing did not finish successfully. Errors occurred while processing data from participants: NDARZZ740MLM (1). Check the HTML reports for details.
```

2. check `.e` (not useful):
```
$ tail fpsub-NDARZZ740MLM.e79892
[INFO] Fetching updates for Dataset(/scratch/rbc/SGE_79892/job-79892-sub-NDARZZ740MLM/ds/pennlinc-containers) 
[INFO] == Command start (output follows) ===== 
+ subid=sub-NDARZZ740MLM
+ mkdir -p /scratch/rbc/SGE_79892/job-79892-sub-NDARZZ740MLM/ds/.git/tmp/wdir
+ singularity run --cleanenv -B /scratch/rbc/SGE_79892/job-79892-sub-NDARZZ740MLM/ds pennlinc-containers/.datalad/environments/fmriprep-20-2-3/image inputs/data prep participant -w /scratch/rbc/SGE_79892/job-79892-sub-NDARZZ740MLM/ds/.git/tmp/wkdir --n_cpus 1 --stop-on-first-crash --fs-license-file code/license.txt --skip-bids-validation --output-spaces MNI152NLin6Asym:res-2 --anat-only --participant-label sub-NDARZZ740MLM --force-bbr --cifti-output 91k -v -v
You are using fMRIPrep-20.2.3, and a newer version of fMRIPrep is available: 21.0.1.
Please check out our documentation about how and when to upgrade:
https://fmriprep.readthedocs.io/en/latest/faq.html#upgrading
[INFO] == Command exit (modification check follows) ===== 
CommandError: 'bash ./code/fmriprep_zip.sh sub-NDARZZ740MLM' failed with exitcode 1 under /scratch/rbc/SGE_79892/job-79892-sub-NDARZZ740MLM/ds
```

3. check `qacct`: `failed` code is `0`:
```
$ qacct -j 79892 -o rbc
...
qsub_time    Mon Apr  4 12:08:55 2022
start_time   Mon Apr  4 12:32:31 2022
end_time     Tue Apr  5 07:47:43 2022
granted_pe   NONE                
slots        1                   
failed       0    
exit_status  1     
...   
category     -U non-deadlineusers -u rbc -l h_stack=256m,h_vmem=16G,tmpfree=200G
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

### Other stalled jobs and got killed due to exceeding `h_rt`:
- fpsub-NDARJP304NK1.e9639520


# PNC and QSIPrep:

## About PNC and QSIPrep:

- audit csv:
	- `/cbica/projects/RBC/production/PNC/QSIPREP_AUDIT.csv`
- where are the log files:
	- `/cbica/projects/RBC/production/PNC/qsiprep/analysis/logs`

## Summary of jobs failed or stalled:
| keywords  | show up in which file | 
| :-- | :--: |
| "git-annex: copy: 1 failed" | in .e |
| "Exception: No dwi images found for " | in .e |