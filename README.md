# convert-mri_study-pams

- convert to dcm2niix
- create a qc qmd file (form dcm2niix's bids json file and fslhd)

## scripts 

1. `bash dcm_unzip.sh`
2. `bash dcm2niix_wrapper.sh`
3. `bash qc_uber.sh`
4. `Rscript qc_combine.R`
5. `bash qc_render.sh`

## dependencies
- bash:
    - epongpipat/bashHelperKennedyRodrigue
- R:
    - epongpipat/rHelperKennedyRodrigue