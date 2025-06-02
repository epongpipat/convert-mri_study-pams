#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load containers/fsl
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(sub ses date)
check_req_args ${req_arg_list[@]}
print_header
set -e

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
in_dir="${root_dir}/study-pams/sourcedata/nii_software-dcm2niix_v-1.0.20210317/KENROD_${study_uc}_${date}_${sub}_${wave}"
in_paths=(`ls ${in_dir}/*.nii.gz`)
out_dir="${root_dir}/study-pams/sourcedata/qc/KENROD_${study_uc}_${date}_${sub}_${wave}/descriptive_stats"
out_path="${root_dir}/study-pams/sourcedata/qc/KENROD_${study_uc}_${date}_${sub}_${wave}/descriptive_stats.csv"

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
if [[ ${#in_paths[@]} -eq 0 ]]; then
    error_msg "no files found in ${in_dir}"
fi

if [[ -f ${out_path} ]] && [[ ${overwrite} -eq 0 ]]; then
    error_msg "file already exists and overwrite set to 0 (${out_path})"
elif [[ -f ${out_path} ]] && [[ ${overwrite} -eq 1 ]]; then
    warning_msg "overwriting, file already exists and overwrite set to 1 (${out_path})"
    rm ${out_path}
fi

if [[ ! -d ${out_dir} ]]; then
    mkdir ${out_dir}
fi

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
hdr="sub,ses,file,mean,sd,min,max,q1,q2,q3,snr,iqr"
echo -e ${hdr} > ${out_path}

for i in ${!in_paths[@]}; do
    file=`basename ${in_paths[$i]}`
    out_path_acq="${out_dir}/${file%.nii.gz}.csv"
    stats=`fsl_exec fslstats ${in_paths[$i]} -M -S -P 0 -P 100 -P 25 -P 50 -P 75`
    stats=`echo ${stats} | sed "s/ /,/g"`
    snr=`awk -v mean=$(echo ${stats} | cut -d, -f1) -v sd=$(echo ${stats} | cut -d, -f2) 'BEGIN{print mean/sd}'`
    iqr=`awk -v q1=$(echo ${stats} | cut -d, -f5) -v q3=$(echo ${stats} | cut -d, -f7) 'BEGIN{print q3-q1}'`
    echo -e "${sub},${ses},${file},${stats},${snr},${iqr}" >> ${out_path}
    echo -e "${hdr}\n${sub},${ses},${file},${stats},${snr},${iqr}" > ${out_path_acq}
done

ensure_permissions ${out_path}

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer
