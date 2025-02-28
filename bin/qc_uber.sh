#!/bin/bash

# ------------------------------------------------------------------------------
# sge options
# ------------------------------------------------------------------------------
#$ -S /bin/bash
#$ -V
#$ -o job-id-$JOB_ID_job-name-$JOB_NAME.log
#$ -j Y

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
module load bashHelperKennedyRodrigue
source bashHelperKennedyRodrigueFunctions.sh

# ------------------------------------------------------------------------------
# args/hdr
# ------------------------------------------------------------------------------
parse_args "$@"
req_arg_list=(sub ses date)
check_req_args ${req_arg_list[@]}
dcm2niix_ver="1.0.20210317"
print_header
set -e

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
root_dir=`get_root_dir kenrod`
code_dir=`dirname $0`
if [[ ${code_dir} =~ '/var/spool/slurm' ]]; then
    code_dir=${slurm_code_dir}
fi

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
# remove leading zeros
opts=`echo ${opts} | sed "s/--ses ${ses}/--ses ${wave}/"`

cmd="bash ${code_dir}/qc_bids_to_csv_wrapper-bash.sh ${opts}"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

cmd="bash ${code_dir}/qc_fslhd_to_csv.sh ${opts}"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}

cmd="bash ${code_dir}/qc_desc_stats.sh ${opts}"
echo -e "\ncommand:\n${cmd}\n"
eval ${cmd}


# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
print_footer
