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
module load convert-mri_study-pams
```

### 2.A. convert
`dcm_unzip.sh`

`dcm2niix_wrapper.sh`

### 2.B. qc
`qc_uber.sh`

`qc_combine_all_sub.sh`

`qc_render.sh # needs to be run locally for now` (or locally render the qc_report.qmd)

`qc_copy_report.sh`
