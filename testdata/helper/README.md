README:

- [rm_jobs_compspace.sh](rm_jobs_compspace.sh) was used to remove failed jobs in
comp_space. It requires `list_rm_jobs_compspace.txt`.
    - This required text file is simply a list of job folders to remove. e.g., [list_rm_jobs_compspace_eg.txt](list_rm_jobs_compspace_eg.txt), or as below:

```
# in `list_rm_jobs_compspace.txt`:

job-0000-sub-02-ses-B
job-0001-sub-02-ses-D
...
```



- Alternative way to remove jobs in comp_space:
```
# first rm will delete everything it can, then chmod and rm the leftovers
$ rm -rf <foldername>
$ chmod -R +w <foldername>
$ rm -rf <foldername>
```
