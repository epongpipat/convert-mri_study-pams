# convert-mri_study-pams

collection of scripts to:
- unzip and convert dcm to nii format (using dcm2niix)
- create a qc html file (from dcm2niix's bids json file and fslhd using qmd)

## 1. dependencies
- bash:
    - epongpipat/bashHelperKennedyRodrigue
- R:
    - epongpipat/rHelperKennedyRodrigue

## 2. usage

```
module load study-pams_convert-mri
```

### 2.A. convert
`unzip_dcm`

`convert_dcm_to_nii`

### 2.B. qc
`qc_uber.sh`

`qc_combine_all_sub.sh`

`qc_render.sh # needs to be run locally for now` (or locally render the qc_report.qmd)

`qc_copy_report.sh`
