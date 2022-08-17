README:

[rm_jobs_compspace.sh](rm_jobs_compspace.sh) was used to remove failed jobs in
comp_space. It requires `list_rm_jobs_compspace.txt`. 

Alternative way to remove jobs in comp_space:
```
# first rm will delete everything it can, then chmod and rm the leftovers
$ rm -rf <foldername>
$ chmod -R +w <foldername>
$ rm -rf <foldername>
```
