#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh

# ------------------------------------------------------------------------------
# hdr
# ------------------------------------------------------------------------------
print_header
set -e

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
code_dir=`dirname $0`
in_path="${code_dir}/qc_report.qmd"
out_dir="${root_dir}/study-pams/sourcedata/qc/docs"

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
cmd="quarto render \
${in_path} \
--to html"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

cmd="rsync -ur ${code_dir}/qc_report_files ${out_dir}/"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

cmd="rsync -u ${code_dir}/qc_report.html ${out_dir}/qc_report.html"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

ensure_permissions ${out_dir}

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer