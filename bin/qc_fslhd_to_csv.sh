#!/bin/bash

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh
module load fsl
# module load R/3.6.0
module load containers/r/4.2.1

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(study sub ses date)
check_req_args ${req_arg_list[@]}
print_header
set -e 

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
# in_dir="${root_dir}/shared/Preclinical_AD_MCI_study/MRI_Testing/raw/s03_nii/sub-${sub}/ses-${ses}"
dcm2niix_ver="1.0.20210317"

declare -A in_paths
in_paths[nii_dir]="${root_dir}/study-${study}/sourcedata/nii_software-dcm2niix_v-${dcm2niix_ver}/KENROD_PAMS_${date}_${sub}_${wave}"
in_paths[code_dir]=`dirname $0`

declare -A out_paths
out_paths[tsv_dir]="${root_dir}/study-${study}/sourcedata/qc/KENROD_${study_uc}_${date}_${sub}_${wave}/fslhd_tsv"
out_paths[csv_dir]="${root_dir}/study-${study}/sourcedata/qc/KENROD_${study_uc}_${date}_${sub}_${wave}/fslhd_csv"
out_paths[csv_combined]="${root_dir}/study-${study}/sourcedata/qc/KENROD_${study_uc}_${date}_${sub}_${wave}/fslhd.csv"

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
check_in_paths ${in_paths[@]}

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
for in_path in ${in_paths[nii_dir]}/*.nii.gz; do
    if [[ ! -d ${out_paths[tsv_dir]} ]]; then
        mkdir -p ${out_paths[tsv_dir]}
    fi
    out_file=`basename ${in_path} | sed s/.nii.gz/.tsv/g`
    cmd="fslhd ${in_path} > ${out_paths[tsv_dir]}/${out_file}"
    eval_cmd -c "${cmd}" -o "${out_paths[tsv_dir]}/${out_file}" --overwrite ${overwrite}
done

for in_path in ${out_paths[tsv_dir]}/*.tsv; do
    if [[ ! -d ${out_paths[csv_dir]} ]]; then
        mkdir -p ${out_paths[csv_dir]}
    fi
    out_file=`basename ${in_path} | sed s/.tsv/.csv/g`
    out_csv="${out_paths[csv_dir]}/${out_file}"
    cmd="r-exec Rscript --vanilla ${in_paths[code_dir]}/qc_fslhd_to_csv.R -i ${in_path} -o ${out_csv} --overwrite ${overwrite}"
    eval_cmd -c "${cmd}" -o "${out_csv}" --overwrite ${overwrite}
done

cmd="r-exec Rscript --vanilla ${in_paths[code_dir]}/qc_fslhd_combine_within_sub.R \
-i ${out_paths[csv_dir]} \
-o ${out_paths[csv_combined]} \
--overwrite ${overwrite}"
eval_cmd -c "${cmd}" -o "${out_paths[csv_combined]}" --overwrite ${overwrite}

ensure_permissions ${out_paths[tsv_dir]}
ensure_permissions ${out_paths[csv_dir]}
ensure_permissions ${out_paths[csv_combined]}

# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer
