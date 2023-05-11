#!/bin/bash

# Copy qc_report to study folder
module load bashHelperKennedyRodrigue
root_dir=`get_root_dir kenrod`
code_dir=`dirname $0`
OUTdir=${root_dir}/study-pams/sourcedata/qc/docs

cp ${code_dir}/qc_report.html $OUTdir/qc_report.html
