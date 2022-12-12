import os
import os.path as op
import glob
import pandas as pd

folder_logs = "/cbica/projects/RBC/production/HBN/fmriprep-anat/analysis/logs"
# folder_logs = "/cbica/projects/RBC/production/HBN/fmriprep-func/analysis/logs"
list_keyword = ["[error]",
                "Cannot allocate memory"]
list_keyword_e_file = ["[error]",
                        "Exception: No T1w images found for"]

df_results = pd.DataFrame(
                    list(zip(
                        list_keyword)),
                    columns=['keyword'])
df_results["count"] = 0

list_o_file = glob.glob(op.join(folder_logs, "*.e*"))
print("There are " + str(len(list_o_file)) + " in this folder...")
selected_file = []
j = 0

for i, o_file in enumerate(list_o_file):
    with open(o_file) as f:
        for line in f:
            for k, keyword in enumerate(list_keyword):
                #print(keyword)
                if keyword in line:  #if keyword.lower() in line.lower():
                    print("'" + keyword + "' from " + o_file)
                    selected_file.append(o_file)
                    j += 1
                    df_results.at[k, "count"] += 1

                    # if (j % 10 == 0) & (j != 0):
                    #     print("Got " + str(j) + " files that contain the keywords!")
                    break
    
    # if (i % 20 == 0) & (i != 0):
    #     print("Have searched " + str(i) + " files....")

print(df_results)