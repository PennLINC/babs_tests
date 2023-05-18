# This is to generate `babs-init` command
# Used by BABS show case

import os.path as op

# ++++++++++++++++++++++++++++++++++++++++++++++++++++
flag_instance = "toybidsapp"   # "fmriprep_anatonly" or "toybidsapp" (for testing only)
flag_where = "msi"    # "cubic" or "local"
# ++++++++++++++++++++++++++++++++++++++++++++++++++++

type_session = "single-ses"

if flag_instance == "toybidsapp":
    project_name = "test_showcase_HBN_toybidsapp"
    bidsapp = "toybidsapp"
    container_name = "toybidsapp-0-0-7"
    config_yaml_filename = "bidsapp-toybidsapp-0-0-7_task-rawBIDS_system-slurm_cluster-MSI_egConfig.yaml"

if flag_where == "cubic":
    where_root = "/cbica/projects/BABS/"
    where_project = op.join(where_root, "babs_showcase")
    input_ds = "/cbica/projects/BABS/babs_showcase/HBN_BIDS"   # path to the input dataset
    container_ds = op.join(where_project, bidsapp + "-container")
    container_config_yaml_file = op.join(where_root, "babs_paper", config_yaml_filename)
elif flag_where == "local":
    where_root = "/Users/chenyzh/Desktop/Research/Satterthwaite_Lab/datalad_wrapper"
    where_project = op.join(where_root, "data")
    # use toy data and toy container for testing only:
    input_ds = op.join(where_project, "w2nu3")
    container_ds = op.join(where_project, "toybidsapp-container-docker")
    container_config_yaml_file = op.join(where_root, "babs_paper", config_yaml_filename)

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
cmd += "\t" + "--type_system " + "sge"

print(cmd)
