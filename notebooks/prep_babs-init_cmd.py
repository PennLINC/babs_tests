# This is to generate `babs-init` command
# Used by BABS show case

import os.path as op

# ++++++++++++++++++++++++++++++++++++++++++++++++++++
flag_instance = "toybidsapp"   # "fmriprep_anatonly" or "toybidsapp" (for testing only)
flag_where = "msi"    # "msi"
type_session = "multi-ses"
# ++++++++++++++++++++++++++++++++++++++++++++++++++++

# system type:
if flag_where == "msi":
    type_system = "slurm"
else:
    type_system = "sge"

if flag_instance == "toybidsapp":
    project_name = "test_babs_" + type_session + "_" + flag_instance
    bidsapp = "toybidsapp"
    container_name = "toybidsapp-0-0-7"
    config_yaml_filename = "bidsapp-toybidsapp-0-0-7_task-rawBIDS_system-slurm_cluster-MSI_egConfig.yaml"

if flag_where == "msi":
    where_root = "/home/faird/zhaoc"
    where_project = "/home/faird/zhaoc/data"
    if type_session == "single-ses":
        input_ds = "https://osf.io/t8urc/"
    elif type_session == "multi-ses":
        input_ds = "https://osf.io/w2nu3/"

    container_ds = op.join(where_project, bidsapp + "-container")
    container_config_yaml_file = op.join(where_root, "babs_tests/notebooks", config_yaml_filename)

list_sub_file = None   # no pre-defined subject list file

cmd = "babs-init \\\n"
cmd += "\t" + "--where_project " + where_project + " \\\n"
cmd += "\t" + "--project_name " + project_name + " \\\n"
cmd += "\t" + "--input " + "BIDS" + " " + input_ds + " \\\n"
if list_sub_file is not None:
    cmd += "\t" + "--list_sub_file " + list_sub_file + " \\\n"
cmd += "\t" + "--container_ds " + container_ds + " \\\n"
cmd += "\t" + "--container_name " + container_name + " \\\n"
cmd += "\t" + "--container_config_yaml_file " + container_config_yaml_file + " \\\n"
cmd += "\t" + "--type_session " + type_session + " \\\n"
cmd += "\t" + "--type_system " + type_system

print(cmd)
