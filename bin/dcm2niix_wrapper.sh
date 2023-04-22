#!/bin/bash

# ------------------------------------------------------------------------------
# load modules
# ------------------------------------------------------------------------------
module load bashHelperKennedyRodrigue/0.0.1
source bashHelperKennedyRodrigueFunctions.sh
dcm2niix_ver="1.0.20210317"
module load dcm2niix/${dcm2niix_ver}

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(sub ses date)
check_req_args ${req_arg_list[@]}

print_header

# ------------------------------------------------------------------------------
# options
# ------------------------------------------------------------------------------
lab="kenrod"
study="pams"

lab_uc="KENROD"
study_uc="PAMS"

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
in_dir="${root_dir}/study-${study}/sourcedata/dcm/${lab_uc}_${study_uc}_${date}_${sub}_${wave}"
out_dir="${root_dir}/study-${study}/sourcedata/nii_software-dcm2niix_v-${dcm2niix_ver}/${lab_uc}_${study_uc}_${date}_${sub}_${wave}"
out_file="sub-${sub}_ses-${ses}_acq-%s-%p"

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
if [[ ! -d ${in_dir} ]]; then
    echo "error: file does not exist (in_dir: ${in_dir})"
    exit 1;
fi

if [[ -d ${out_dir} ]] && [ ! -z "$(ls -A ${out_dir})" ] && [[ ${overwrite} -eq 0 ]]; then
    echo "error: non-empty directory exists and overwrite set to 0 (out_dir: ${out_dir})"
    exit 1;
fi

# ------------------------------------------------------------------------------
# code 
# ------------------------------------------------------------------------------
# create output directory
if [[ ! -d ${out_dir} ]]; then
    mkdir ${out_dir}
fi

# convert dicom to nifti
cmd="dcm2niix \
-b y \
-ba y \
-f ${out_file} \ 
-i y \
-o ${out_dir} \
-z y \
${in_dir}"

echo -e "\ncommand:\n${cmd}\n"
eval ${cmd} | tee -a ${out_dir}/dcm2niix.log

cmd="chmod -R 2775 ${out_dir}"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

# ------------------------------------------------------------------------------
# print footer
# ------------------------------------------------------------------------------
print_footer