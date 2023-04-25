
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

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
declare -A in_paths
in_paths[zip]="${root_dir}/incoming/${scanner_center}/${lab_uc}-${lab_uc}.${study_uc}.${data_ref}.zip"

declare -A out_paths
out_paths[dcm_dir]="${root_dir}/study-${study}/sourcedata/dcm"
out_paths[sub_dcm_dir_temp]="${root_dir}/study-${study}/sourcedata/dcm/${lab_uc_abbr}_${study_uc}_${sub}_${wave}\ ${sub}/${lab_uc}\ ${study_uc}"
out_paths[sub_dcm_dir_temp2]="${root_dir}/study-${study}/sourcedata/dcm/${lab_uc_abbr}_${study_uc}_${sub}_${wave}\ ${sub}/"
out_paths[sub_dcm_dir]="${root_dir}/study-${study}/sourcedata/dcm/${lab_uc}_${study_uc}_${date}_${sub}_${wave}"

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
check_in_paths ${in_paths[@]}

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
cmd="unzip \
${in_paths[zip]} \
-d ${out_paths[dcm_dir]}"
echo -e "\ncommand:\n${cmd}"
eval ${cmd}

cmd="mv ${out_paths[sub_dcm_dir_temp]} \
${out_paths[sub_dcm_dir]}"
echo -e "\ncommand:\n${cmd}"
eval ${cmd}

cmd="ensure_permissions ${out_paths[sub_dcm_dir]}"
echo -e "\ncommand:\n${cmd}"
eval ${cmd}

cmd="rm -r ${out_paths[sub_dcm_dir_temp2]}"
echo -e "\ncommand:\n${cmd}"
eval ${cmd}

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer