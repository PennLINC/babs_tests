#!/usr/bin/env python3
# ref: https://github.com/bids-apps/example/blob/master/run.py

import argparse
import os
import subprocess
import shutil
import tempfile

def run(command, env={}):
    merged_env = os.environ
    merged_env.update(env)
    process = subprocess.Popen(command, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, shell=True,
                               env=merged_env)
    while True:
        line = process.stdout.readline()
        line = str(line, 'utf-8')[:-1]
        print(line)
        if line == '' and process.poll() != None:
            break
    if process.returncode != 0:
        raise Exception("Non zero return code: %d"%process.returncode)

parser = argparse.ArgumentParser(description='Example BIDS App entrypoint script.')
parser.add_argument('input_dir', help='The directory of the (unzipped) input dataset, '
                    'or the path to the zipped dataset; '
                    'unzipped dataset should be formatted according to the BIDS standard.')
parser.add_argument('output_dir', help='The directory where the output files '
                    'should be stored. If you are running group level analysis '
                    'this folder should be prepopulated with the results of the'
                    'participant level analysis.')
parser.add_argument('analysis_level', help='Level of the analysis that will be performed. '
                    'Multiple participant level analyses can be run independently '
                    '(in parallel) using the same output_dir.',
                    choices=['participant', 'group'])
parser.add_argument('--participant_label', '--participant-label',
                    help='The label of the participant that should be analyzed. The label '
                    'can either be <sub-xx>, or just <xx> which does not include "sub-"')
parser.add_argument('--session_label', '--session-label', '--ses_label', '--ses-label',
                    help='The label of the session that should be analyzed. The label '
                    'can either be <ses-xx>, or just <xx> which does not include "ses-"')
parser.add_argument('--zipped',
                    help="Whether the input dataset is zipped (--zipped) or not (--no-zipped).",
                    action=argparse.BooleanOptionalAction)

args = parser.parse_args()

# Sanity checks:
if args.participant_label:
    if "sub-" == args.participant_label[0:4]:
        participant_label = args.participant_label
    else:
        participant_label = "sub-" + args.participant_label

print("participant: " + participant_label)

if args.session_label:
    if "ses-" == args.session_label[0:4]:
        session_label = args.session_label
    else:
        session_label = "ses-" + args.session_label

    print("session: " +session_label)

# The meat:
if args.analysis_level == "participant":
    if not args.participant_label:     # did not provide --participant_label
        raise Exception("Requested running at participant level, but did not provide --participant_label!")

    # check whether the input dataset is zipped or not; define `dir_4analysis`
    if args.zipped is True:
        print("Input dataset is zipped... Unzip to a temporary folder first...")
        # `args.input_dir` is the zipped filename
        # unzip to a temporary folder and get the foldername
        temp_unzip_to = tempfile.mkdtemp()
        shutil.unpack_archive(args.input_dir, temp_unzip_to)

        # TODO: define `dir_4analysis``:

    elif args.zipped is False:
        if args.session_label:
            dir_4analysis = os.path.join(args.input_dir, participant_label, session_label)
        else:   # did not provide session label
            print("did not provide --session_label; will count files in this participant's folder")
            dir_4analysis = os.path.join(args.input_dir, participant_label)

        temp_unzip_to = None
    else:
        print("invalid zipping type!")

    # print(dir_4analysis)
    print('Recursively counting number of non-hidden files in: ', dir_4analysis)

    # count:
    num_files = 0
    for base, dirs, files in os.walk(dir_4analysis):

        for Files in files:
            if "." == Files[0]:    # if it's a hidden file, skip
                continue
            else:
                #print(Files)
                num_files += 1

    print(num_files)

    # remove temporary folder:
    if temp_unzip_to is not None:
        shutil.rmtree(temp_unzip_to)

    # save the number into an output.csv:
    fn_output = os.path.join(args.output_dir, "num_nonhidden_files.txt")
    with open(fn_output, 'w') as f:
        f.write(str(num_files))


#print()
