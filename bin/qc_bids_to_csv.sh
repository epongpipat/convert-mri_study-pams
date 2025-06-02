#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
# module load python/3.8.6
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh
# module load miniconda
module load containers/python/3.13.3

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(study sub ses date)
check_req_args ${req_arg_list[@]}
dcm2niix_ver="1.0.20210317"
print_header
set -e

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
in_dir="${root_dir}/study-${study}/sourcedata/nii_software-dcm2niix_v-${dcm2niix_ver}/KENROD_${study_uc}_${date}_${sub}_${wave}"
out_dir="${root_dir}/study-${study}/sourcedata/qc/KENROD_${study_uc}_${date}_${sub}_${wave}/bids_json_to_csv"
code_dir=`dirname $0`

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
check_in_paths ${in_dir}

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------

cmd="python-exec python ${code_dir}/qc_bids_to_csv.py \
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