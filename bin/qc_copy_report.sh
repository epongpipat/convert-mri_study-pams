#!/bin/bash

# Copy qc_report to study folder

# modules
module load bashHelperKennedyRodrigue

# paths
root_dir=`get_root_dir kenrod`
code_dir=`dirname $0`
OUTdir=${root_dir}/study-pams/sourcedata/qc/docs

# main
cmd="cp ${code_dir}/qc_report.html ${OUTdir}/qc_report.html"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

ensure_permissions ${OUTdir}/qc_report.html
