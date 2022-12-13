import os
import os.path as op
import glob
import pandas as pd
import numpy as np
import subprocess
import re
import time

t = time.time()
__location__ = os.path.realpath(
            os.path.join(os.getcwd(), os.path.dirname(__file__)))

username_lowercase = "rbc"   # can be got by `whoami` in terminal
dataset = "HBN"
which_bidsapp = "fmriprep-anat"    # "fmriprep-anat" or "fmriprep-func"
n_logs = -1   # for all: -1   # ++++++++++++++++++++++++++++++

folder_logs = "/cbica/projects/RBC/production/" + dataset + "/" + which_bidsapp + "/analysis/logs"
fn_df_failed_jobs = op.join(__location__, dataset + "_" + which_bidsapp + "_failed_jobs.csv")

list_keyword_o_file = ["Cannot allocate memory",
                       "mris_curvature_stats: Could not open file",
                       "Numerical result out of range",
                       "fMRIPrep failed"]
list_keyword_e_file = ["Exception: No T1w images found for"]
# "[error]"

# df_results = pd.DataFrame(
#                     list(zip(
#                         list_keyword)),
#                     columns=['keyword'])
# df_results["count"] = 0

list_o_file = glob.glob(op.join(folder_logs, "*.o*"))
print("There are " + str(len(list_o_file)) + " in this folder...")
print("Will search " + str(n_logs) + " jobs' log files...")
list_failed_file = []
keywords_in_failed_file = []
list_which_file_failed = []

for i, o_file in enumerate(list_o_file):
    o_filename = op.basename(o_file)
    e_file = o_file.replace(".o", ".e")
    e_filename = op.basename(e_file)
    job_id_str = o_filename.split(".o")[1]
    job_name = o_filename.split(".o")[0]
    is_failed = np.nan
    found_error = False
    # check whether it's a failed job (has `SUCCESS` at the end):
    
    with open(o_file, 'r') as f:
        last_line = f.readlines()[-1]
    if last_line.replace("\n", "") == "SUCCESS":
        is_failed = False
    else:
        is_failed = True

    if is_failed:   # TODO: o file or e file
        list_failed_file.append(o_filename)

        # o file:
        with open(o_file) as f:
            for line in f:
                for k, keyword in enumerate(list_keyword_o_file):
                    #print(keyword)
                    if keyword in line:  #if keyword.lower() in line.lower():
                        print("'" + keyword + "' from " + o_filename)
                        keywords_in_failed_file.append(keyword)
                        list_which_file_failed.append('.o')
                        found_error = True
                        # if (j % 10 == 0) & (j != 0):
                        #     print("Got " + str(j) + " files that contain the keywords!")
                        break
                    
                if found_error:
                    break

        if not found_error:   # try `.e` file:
            with open(e_file) as f:
                for line in f:
                    for k, keyword in enumerate(list_keyword_e_file):
                        #print(keyword)
                        if keyword in line:  #if keyword.lower() in line.lower():
                            print("'" + keyword + "' from " + e_filename)
                            keywords_in_failed_file.append(keyword)
                            list_which_file_failed.append('.e')
                            found_error = True
                            # if (j % 10 == 0) & (j != 0):
                            #     print("Got " + str(j) + " files that contain the keywords!")
                            break
                        
                    if found_error:
                        break

        if not found_error:   # did not find keyword:
            # try `qacct`:
            proc_qacct = subprocess.run(
                ["qacct", "-o", username_lowercase,
                "-j", job_id_str],
                stdout=subprocess.PIPE
            )
            proc_qacct.check_returncode()
            msg = proc_qacct.stdout.decode('utf-8')
            # msg = msg.replace("\n", " ")   # remove `\n`, otherwise `re` cannot detect
            list_qacct_failed = re.findall(r'(?:failed)(.*?)(?:\n)', msg)  # find all, return a list
            # ^^ between `failed` and `\n`
            # example output: ['      xcpsub-00000   ', '      fpsub-0000  ']
            if len(list_qacct_failed) > 1:   # more than one job were found:
                # determine which is the job we want:
                list_jobnames = re.findall(r'(?:jobname)(.*?)(?:\n)', msg)
                for i_temp, temp_jobname in enumerate(list_jobnames):
                    if job_name == temp_jobname.replace(" ", ""):  # remove spaces:
                        # ^^ the job name we want to find:
                        qacct_failed = list_qacct_failed[i_temp]
                        break
            elif len(list_qacct_failed) == 1:
                qacct_failed = list_qacct_failed[0]
            else:
                raise Exception("did not find qacct for: " + o_filename)
            
            # example: '       0    '
            qacct_failed = qacct_failed.strip()    # remove the spaces at the beginning and the end

            if qacct_failed != "0":   # field `failed` is not '0', i.e., was not success:
                found_error = True
                print("'" + qacct_failed + "' from qacct of " + o_filename)
                keywords_in_failed_file.append(qacct_failed)
                list_which_file_failed.append('qacct failed')

         # if still cannot detect the error, then still update `keywords_in_failed_file` 
        if not found_error:
            print("Warning!! Did not find the error message for " + o_filename + "!")
            keywords_in_failed_file.append("BABS did not find the keyword")
            list_which_file_failed.append(np.nan)
    
    if (i % 20 == 0) & (i != 0):
        print("\tHave searched " + str(i) + " jobs....")
    if i == n_logs:
        break
print("In total have searched " + str(i) + " jobs.")

# Save the gathered lists into a csv file:
df_failed_jobs = pd.DataFrame(
                    list(zip(
                        list_failed_file, keywords_in_failed_file,
                        list_which_file_failed)),
                    columns=['failed', 'keywords',
                             'found_in_which_file'])
df_failed_jobs.to_csv(fn_df_failed_jobs, index=False)

print("There are " + str(df_failed_jobs.shape[0]) + " failed jobs (without `SUCCESS` at the end).")

summary_df = df_failed_jobs["keywords"].value_counts()
print("Summary table:")
print(summary_df)

elapsed = time.time() - t
print("Took " + str(elapsed) + " to perform searching in " + str(i) + " jobs.")