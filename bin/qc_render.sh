#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh
# module load R/4.2.1
# module load quarto
module load containers/r/4.2.1-quarto

# ------------------------------------------------------------------------------
# hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(study)
check_req_args ${req_arg_list[@]}
print_header
set -e

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
code_dir=`dirname $0`
in_path="${code_dir}/qc_report.qmd"

declare -A out_paths
out_paths[dir]="${root_dir}/study-${study}/sourcedata/qc/docs"
out_paths[file]="qc_report.html"
out_paths[path_tmp]="${code_dir}/${out_paths[file]}"
out_paths[path]="${out_paths[dir]}/${out_paths[file]}"

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------

# Rscript ${code_dir}/check_pkgs.R
# export QUARTO_R_ARGS="--vanilla"
cmd="cd ${code_dir}; r-exec quarto render \
${in_path} \
--to html \
--output ${out_paths[file]}"
#--output-dir ${out_paths[dir]}"
# echo -e "\ncommand:\n${cmd}\n"
# eval ${cmd}
eval_cmd -c "${cmd}" -o ${out_paths[path_tmp]} --overwrite ${overwrite} --print ${print}

# cmd="rsync -ur ${code_dir}/qc_report_files ${out_dir}/"
# echo -e "\ncommand:\n${cmd}\n"
# eval ${cmd}

cmd="rsync -u ${out_paths[path_tmp]} ${out_paths[path]}"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}
ensure_permissions ${out_paths[path]}
# ensure_permissions ${out_dir}

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer