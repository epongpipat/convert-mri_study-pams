# convert-mri_study-pams

- convert to dcm2niix
- create a qc qmd file (form dcm2niix's bids json file and fslhd)

## scripts 

1. bash dcm_unzip.sh
2. bash dcm2niix_wrapper.sh
3. bash qc_bids_to_csv.sh
4. bash qc_fslhd_to_csv.sh
5. Rscript qc_combine.R
6. bash qc_render.sh

## dependencies
- bash:
    - epongpipat/bashHelperKennedyRodrigue
- R:
    - epongpipat/rHelperKennedyRodrigue