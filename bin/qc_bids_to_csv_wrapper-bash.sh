#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load python/3.8.6
module load bashHelperKennedyRodrigue/0.0.1
source bashHelperKennedyRodrigueFunctions.sh

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(sub ses date)
check_req_args ${req_arg_list[@]}
dcm2niix_ver="1.0.20210317"
print_header

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
in_dir="${root_dir}/study-pams/sourcedata/nii_software-dcm2niix_v-${dcm2niix_ver}/KENROD_PAMS_${date}_${sub}_${wave}"
out_dir="${root_dir}/study-pams/sourcedata/qc/KENROD_PAMS_${date}_${sub}_${wave}/bids_json_to_csv"
code_dir=`dirname $0`

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
check_in_paths ${in_dir}

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------

cmd="python3 ${code_dir}/json_to_csv.py \
-i ${in_dir} \
-o ${out_dir} \
--overwrite ${overwrite}"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

ensure_permissions `dirname ${out_dir}`

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer