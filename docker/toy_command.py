#!/usr/bin/env python3
# Some code below was copied or modified from:
# [An example BIDS App GitHub repository](https://github.com/bids-apps/example)
# which has Apache License.
# e.g., from this script: https://github.com/bids-apps/example/blob/master/run.py
# See LICENSE for license for this toy BIDS App and license for `bids-apps/example`.

"""
This is to count non-hidden files for:
- either a BIDS dataset (`--no-zipped`), # of files in a subject (or session) 's directory
- or zipped BIDS-derivative dataset (`--zipped`), # of files in a subject (or session)'s zip file

Results:
----------
The final result (a text file that includes the count) will be saved to
`<output_dir>/toybidsapp` directory.

Notes:
--------
1. Please note that this is used with `participant_job.sh` in FAIRly big workflow.
   Therefore, `participant_job.sh` (but not this python script)
   will unzip the input dataset if needed
2. Please note that this toy BIDS App does not support `--bids-filter-file` right now.
   Although there is an argument called `--session-label`, this argument cannot be automatically
   handled by software BABS.
   !! In short, when using BABS + toy BIDS App:
   1. If input dataset is not zipped, this toy BIDS App counts at subject-level,
      even if it's a multi-session dataset.
   2. If input dataset is zipped, then this toy BIDS App counts files
      in each subject or session's zip file (depending on it's single- or multi-ses dataset)
3. Currently it does not support `analysis_level` of 'group', and only accepts one participant
   in `--participant_label`.
"""

import argparse
import os
import os.path as op


def cli():
    parser = argparse.ArgumentParser(
        description='Example BIDS App entrypoint script.')
    parser.add_argument(
        'input_dir',
        help='The directory of the (unzipped) input dataset, '
        'or the path to the zipped dataset; '
        'unzipped dataset should be formatted according to the BIDS standard.')
    # Note: should not specify `required=True` or positional arguments
    parser.add_argument(
        'output_dir',
        help='The directory where the output files should be stored')
    parser.add_argument(
        'analysis_level',
        choices=['participant'],
        help='Level of the analysis that will be performed.'
        " Currenlty only 'participant' is allowed.")
    parser.add_argument(
        '--participant_label', '--participant-label',
        help='The label of the participant that should be analyzed. The label'
        ' can either be <sub-xx>, or just <xx> which does not include "sub-".'
        " Currently only one participant label is allowed.",
        required=True)
    parser.add_argument(
        '--session_label', '--session-label', '--ses_label', '--ses-label',
        help='For multi-session dataset, the label of the session that should be analyzed.'
        ' The label can either be <ses-xx>, or just <xx> which does not include "ses-".'
        " Currently only one session label is allowed.")
    # Note: BABS won't be able to automatically add this ^^ variable.
    parser.add_argument(
        '--zipped',
        action=argparse.BooleanOptionalAction,
        help="Use `--zipped` to specify that input dataset is zipped,"
        " And use `--no-zipped` to specify that input dataset is not zipped"
        " (e.g., raw BIDS dataset).",
        required=True)
    parser.add_argument(
        '--dummy',
        help="Dummy variable that takes any values.")
    parser.add_argument(
        "-v", "--verbose",
        dest="verbose_count",
        action="count",
        default=0,
        help="Log verbosity will increase for each occurrence of this argument."
        " This is a dummy variable which won't affect how the messages are printed.")

    return parser


def main():

    args = cli().parse_args()

    # Sanity checks and preparations: --------------------------------------------
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

        print("session: " + session_label)

    # check and make output dir:
    if op.exists(args.output_dir) is False:
        os.makedirs(args.output_dir)

    # verbose level - does not really affect anything:
    print("verbose level: " + str(args.verbose_count)
          + " (This is also a dummy argument and won't really affect printed messages)")

    # dummy variable `--dummy`:
    print("dummy argument `--dummy`: " + str(args.dummy))

    # The meat: ----------------------------------------------------
    if args.analysis_level == "participant":
        if not args.participant_label:     # did not provide --participant_label
            raise Exception(
                "Requested running at participant level, but did not provide --participant_label!")

        if args.zipped is False:
            # need to figure out the specific subj, specific session:
            if args.session_label:
                dir_4analysis = os.path.join(
                    args.input_dir, participant_label, session_label)
            else:   # did not provide session label
                print(
                    "did not provide --session_label;"
                    + " will count files in this participant's folder")
                dir_4analysis = os.path.join(args.input_dir, participant_label)
        elif args.zipped is True:
            # no need to figure out which dir to analyze -
            #   has been done in `participant_job.sh` in BABS
            # e.g., for multi-ses data, BABS will unzip `${subid}_${sesid}_*fmriprep*.zip`
            # for single-ses data, BABS will unzip `${subid}_*fmriprep*.zip`
            # either case, BABS will get a folder called `fmriprep`,
            # and toy BIDS App will just count files in `fmriprep`
            dir_4analysis = args.input_dir
        else:
            raise Exception("invalid zipping type!")

        # print(dir_4analysis)
        print('Recursively counting non-hidden files in: ' + dir_4analysis)

        # count:
        num_files = 0
        for base, dirs, files in os.walk(dir_4analysis):

            for Files in files:
                if "." == Files[0]:    # if it's a hidden file, skip
                    continue
                else:
                    # print(Files)
                    num_files += 1

        print("There are " + str(num_files) + " non-hidden file(s).")

        # save the number into an output.csv:
        results_dir = op.join(args.output_dir, "toybidsapp")
        if op.exists(results_dir) is False:
            os.makedirs(results_dir)
        fn_output = os.path.join(results_dir, "num_nonhidden_files.txt")
        with open(fn_output, 'w') as f:
            f.write(str(num_files) + "\n")


if __name__ == "__main__":
    main()
