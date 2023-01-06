# This is to test out BABS `babs-submit` and `babs-status`
# using HBN dataset and fMRIPrep --anat-only (FreeSurfer)

# How to use this:
#   run `babs-status` in the terminal
#   then, run this python file

import os
import os.path as op
import numpy as np
import pandas as pd

# ++++++++++++++++++++++++++++++++++++++++
list_jobs_submitted = \
    ["sub-NDARNZ043VH0",   # success | finished within 18h (actual time: to check)
     "sub-NDARJT730WP0",   # success | finished within 18h (actual time: to check)
     "sub-NDARNM147CG2",   # failed with alert keyword
     "sub-NDARKA085YRG",   # failed with alert keyword (4 days +); or longer than 1 day; or success (4 days +)
     "sub-NDARNK064DXY",   # failed with alert keyword
     "sub-NDARZZ740MLM",   # failed with alert keyword | also finished within 18h???
     "sub-NDARHK598YJC",   # stuck, without alert keyword
     "sub-NDARGL085RTW",   # stuck, without alert keyword
     ]

fn_csv = "/cbica/projects/BABS/data/test_babs_single-ses_HBN_fmriprep_anatonly/analysis/code/job_status.csv"

# ++++++++++++++++++++++++++++++++++++++++

df = pd.read_csv(fn_csv, dtype={"job_id": 'int','has_submitted': 'bool','is_done': 'bool'})

df_submitted = df.loc[df["sub_id"].isin(list_jobs_submitted)]

with pd.option_context('display.max_rows', None,
                       'display.max_columns', None,
                       'display.width', 120):   # default is 80 characters...
    print(df_submitted)

with pd.option_context('display.max_rows', None,
                       'display.max_columns', None,
                       'display.width', 120,
                       "display.max_colwidth", None): 
    print(df_submitted["last_line_o_file"])

with pd.option_context('display.max_rows', None,
                       'display.max_columns', None,
                       'display.width', 120):   # default is 80 characters...
    print(df.head())    # first 5 rows

# running jobs:
with pd.option_context('display.max_rows', None,
                       'display.max_columns', None,
                       'display.width', 120):   # default is 80 characters...
    print(print(df.iloc[900:910]))

# # failed jobs: (quite a few, though as expected; commented now) ----------------------
# df_failed = df.loc[df["is_failed"]==True]
# with pd.option_context('display.max_rows', None,
#                        'display.max_columns', None,
#                        'display.width', 120):   # default is 80 characters...
#     print(df_failed)

# .o file: Excessive topologic defect encountered # also: Cannot allocate memory:
# sub-NDARAC853DTE   # as in RBC
# sub-NDARAW298ZA9

# no alert message:
# qacct: failed: 19  : before writing exit_status
# sub-NDAREJ923FZU
# sub-NDARET653TAM

# pending jobs: ------------------
# last subject: sub-NDARZZ810LVF 

print("")