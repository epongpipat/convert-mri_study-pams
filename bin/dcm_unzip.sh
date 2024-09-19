
#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(sub ses date data_ref)
check_req_args ${req_arg_list[@]}
print_header

# ------------------------------------------------------------------------------
# options
# ------------------------------------------------------------------------------
lab="kenrod"
lab_uc="KENROD"
lab_uc_abbr="KRO"
study="pams"
study_uc="PAMS"
scanner_center="bhic"
data_ref_1=`echo ${data_ref} | cut -d'-' -f1`

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`

declare -A in_paths
in_paths[zip]="${root_dir}/incoming/${scanner_center}/${lab_uc}-${lab_uc}.${study_uc}.${data_ref}.zip"

declare -A out_paths
out_paths[dcm_dir]="${root_dir}/study-${study}/sourcedata/dcm"
out_paths[sub_dcm_dir_temp]="${root_dir}/study-${study}/sourcedata/dcm/${lab_uc_abbr}_${study_uc}_${sub}_${wave}-${data_ref_1}"
out_paths[sub_dcm_dir]="${root_dir}/study-${study}/sourcedata/dcm/${lab_uc}_${study_uc}_${date}_${sub}_${wave}"

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
check_in_paths ${in_paths[@]}

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
if [[ -d ${out_paths[sub_dcm_dir]} ]] && [[ ${overwrite} == 0 ]]; then
    warning_msg "skipping, file already exists and overwrite is set to 0 (${out_paths[sub_dcm_dir]})"
else
    cmd="unzip \
    ${in_paths[zip]} \
    -d ${out_paths[dcm_dir]}"
    eval_cmd -c "${cmd}" -o ${out_paths[sub_dcm_dir_temp]} --overwrite ${overwrite} --print ${print}
fi

cmd="mv ${out_paths[sub_dcm_dir_temp]} \
${out_paths[sub_dcm_dir]}"
eval_cmd -c "${cmd}" -o ${out_paths[sub_dcm_dir]} --overwrite ${overwrite} --print ${print}

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer