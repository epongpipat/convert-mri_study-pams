# ------------------------------------------------------------------------------
# argparse
# ------------------------------------------------------------------------------
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser()
parser$add_argument("-i", "--in_dir", help="directory to csv",required = TRUE)
parser$add_argument("-o", "--out_path", help="directory to output",required = TRUE)
# parser$add_argument("--date", help="date (format: YYYYMMDD)",required = TRUE)
parser$add_argument("--overwrite", help="flag to overwrite <0|1> (default: 0)", default = 0)
args <- parser$parse_args()
wave <- as.numeric(args$ses)
# ------------------------------------------------------------------------------
# pkgs
# ------------------------------------------------------------------------------
pkgs <- c('glue', 'dplyr', 'tidyr', 'stringr', 'abind',
          'rHelperKennedyRodrigue')
xfun::pkg_attach2(pkgs, message = F)

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
# argssub <- args$sub
# args$ses <- str_pad(args$ses, 2, 'left', pad = "0")
# overwrite <- args$overwrite
# root_dir <- get_root_dir('kenrod')
# in_paths_str <- glue("{root_dir}/shared/Preclinical_AD_MCI_study/MRI_Testing/raw/s04_qc/sub-{args$sub}/ses-{args$ses}/fslhd/sub-{args$sub}_ses-{args$ses}_*.csv")
# in_paths_str <- glue("{root_dir}/study-pams/sourcedata/qc/KENROD_PAMS_{args$date}_{args$sub}_{wave}/fslhd_csv/*.csv")


# cat(glue("in_paths_str: {in_paths_str}"))
in_paths <- Sys.glob(glue("{args$in_dir}/*.csv")) %>%
  str_subset('localizer', T)
# out_paths <- list()

# out_paths['full'] <- glue("{root_dir}/shared/Preclinical_AD_MCI_study/MRI_Testing/raw/s04_qc/sub-{args$sub}/ses-{args$ses}/fslhd.csv")
# out_paths['simple'] <- glue("{root_dir}/shared/Preclinical_AD_MCI_study/MRI_Testing/raw/s04_qc/sub-{args$sub}/ses-{args$ses}/fslhd_simple.csv")

# out_paths['full'] <- glue("{out_dir}/fslhd.csv")
# out_paths['simple'] <- glue("{out_dir}/fslhd_simple.csv")

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
if (length(in_paths) == 0) {
  stop(glue("error: there are no input files ({in_paths_str})"))
}

# for (key in names(out_paths)) {
  if (file.exists(args$out_path) & args$overwrite == 0) {
    stop(glue("error: file already exists and overwrite set to 0 {args$out_path}"))
  } else if (file.exists(args$out_path) & args$overwrite == 1) {
    unlink(args$out_path)
    warning(glue("warning: overwriting, file already exists and overwrite set to 1 {args$out_path}"))
  }
# }

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
data <- lapply(in_paths, read.csv)

# get_acq <- function(path) {
#   path %>%
#     str_split('/') %>%
#     unlist() %>%
#     str_subset('acq') %>%
#     str_split('_') %>%
#     unlist() %>%
#     str_subset('acq') %>%
#     str_split('-') %>%
#     unlist() %>%
#     .[[2]] %>%
#     as.numeric()
# }

df <- data.frame(abind(data, along = 1)) %>%
  mutate(file = basename(in_paths)) %>%
  rowwise() %>%
  mutate(acq = get_value_from_path(file, 'acq')) %>%
  ungroup() %>%
  select('sub', 'ses', 'acq', 'file', everything()) %>%
  arrange(sub, ses, acq) %>% 
  separate(col = descrip, sep = ';', into = c('te', 'time', 'phase', 'mb'), remove = FALSE) %>%
  mutate(te = str_remove(te, 'TE='),
         time = str_remove(time, 'Time='),
         phase = str_remove(phase, 'phase='),
         mb = str_remove(mb, 'mb='),
         dim0 = as.numeric(dim0),
         dim1 = as.numeric(dim1),
         dim2 = as.numeric(dim2),
         dim3 = as.numeric(dim3),
         dim4 = as.numeric(dim4),
         dim5 = as.numeric(dim5),
         dim6 = as.numeric(dim6),
         dim7 = as.numeric(dim7),
         pixdim0 = as.numeric(dim0),
         pixdim1 = as.numeric(pixdim1),
         pixdim2 = as.numeric(pixdim2),
         pixdim3 = as.numeric(pixdim3),
         pixdim4 = as.numeric(pixdim4),
         pixdim5 = as.numeric(pixdim5),
         pixdim6 = as.numeric(pixdim6),
         pixdim7 = as.numeric(pixdim7),
         dim1_mm = dim1 * pixdim1,
         dim2_mm = dim2 * pixdim2,
         dim3_mm = dim3 * pixdim3,
         vox_vol = pixdim1 * pixdim2 * pixdim2,
         total_vox = dim1 * dim2 * dim3,
         total_vol = vox_vol * total_vox
          )

# df_simple <- df %>%
#   select(sub,	ses,	acq,	file, vox_units, time_units, contains('dim'), vox_vol, total_vol,	contains('form'),	te, time, phase, mb)

# save
write.csv(df, args$out_path, row.names = F)
# write.csv(df_simple, out_paths[['simple']], row.names = F)

# system(glue("chmod 0774 {out_paths[['full']]}"))
# system(glue("chmod 0774 {out_paths[['simple']]}"))