#!/bin/R

# ------------------------------------------------------------------------------
# pkgs
# ------------------------------------------------------------------------------
pkgs <- c('abind', 'glue', 'stringr', 'purrr', 'dplyr', 
          'tidyr', 'rHelperKennedyRodrigue')
xfun::pkg_attach2(pkgs, message = F)
options(warn=1)

# ------------------------------------------------------------------------------
# options
# ------------------------------------------------------------------------------
acq_list <- c('MPRAGE', 'fmri_task-circles', "fmri_task-circles_fmap_dir-pa", "fmri_task-circles_fmap_dir-ap", '3D_T2', 
              'HIRES_T2', 'NODDI', 'NODDI_fmap_dir-pa', 'T2W_FLAIR_2D', 'tgse_pcasl_ve11c_Multidelay', 
              'tgse_pcasl_ve11c_Multidelay_fmap_dir-ap', 'tgse_pcasl_ve11c_Multidelay_fmap_dir-pa')

swi_list_mag <- paste0('SWI_e', 1:8)
swi_list_phase <- paste0('SWI_e', 1:8, '_ph')
# acq <-

acq_list <- c(acq_list, swi_list_mag, swi_list_phase)
acq_list <- c(acq_list, 'B1Map_TURBOFLASH', 'B1Map_TURBOFLASH_UP2mm')

# acq_list <- c('B1Map_TURBOFLASH', 'B1Map_TURBOFLASH_UP2mm')


# acq <- acq_list[29]
vars_str_fslhd_all <- c('sub', 'ses', 'data_type', 'vox_units', 'time_units', 
                    'slice_name', 'intent', 'intent_name', 'qform_name', 'qform_xorient', 
                    'qform_yorient', 'qform_zorient', 'sform_name', 'sform_xorient', 'sform_yorient', 
                    'sform_zorient', 'file_type', 'descrip', 'aux_file', 'acq')

vars_str_bids_all <- c('sub', 'ses', 'Modality', 'Manufacturer', 'ManufacturersModelName', 'InstitutionName', 
                   'InstitutionalDepartmentName', 'InstitutionAddress', 'StationName', 'BodyPartExamined', 'PatientPosition', 
                   'ProcedureStepDescription', 'SoftwareVersions', 'MRAcquisitionType', 'SeriesDescription', 'ProtocolName', 
                   'ScanningSequence', 'SequenceVariant', 'ScanOptions', 'SequenceName', 'ImageType', 
                   'ImageType_2', 'ImageType_3', 'ImageType_4', 'ImageType_5', 'AcquisitionTime', 
                   'ReceiveCoilName', 'ReceiveCoilActiveElements', 'PulseSequenceDetails', 'ConsistencyInfo', 'InPlanePhaseEncodingDirectionDICOM', 
                   'ConversionSoftware', 'ConversionSoftwareVersion', 'PhaseEncodingDirection', 'DiffusionScheme', 'ImageComments',
                   'acq', 'PhaseEncodingDirection', 'ScanOptions')

vars_str_descriptive_stats <- c('sub', 'ses', 'file')

# ------------------------------------------------------------------------------
# functions
# ------------------------------------------------------------------------------
# get_acq_from_path <- function(x) {
#   x %>%
#     basename() %>%
#     str_split('_') %>%
#     unlist() %>%
#     str_subset('acq') %>%
#     str_remove('acq-')
# }


# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
for (acq in acq_list) {
  
  cat(acq, '\n')
  
  # ------------------------------------------------------------------------------
  # paths
  # ------------------------------------------------------------------------------
  root_dir <- get_root_dir('kenrod')
  in_paths <- list()
  in_paths[['fslhd']] <- Sys.glob(glue("{root_dir}/study-pams/sourcedata/qc/KENROD_PAMS_????????_*_?/fslhd_csv/*{acq}.csv"))
  in_paths[['bids']] <- Sys.glob(glue("{root_dir}/study-pams/sourcedata/qc/KENROD_PAMS_????????_*_?/bids_json_to_csv/*{acq}.csv"))
  in_paths[['desc_stats']] <- Sys.glob(glue("{root_dir}/study-pams/sourcedata/qc/KENROD_PAMS_????????_*_?/descriptive_stats/*{acq}.csv"))
  out_dir <- glue("{root_dir}/study-pams/sourcedata/qc/data")
  
  out_file <- case_when(
    acq == "MPRAGE" ~ "type-anat_suffix-T1w",
    acq == 'fmri_task-circles' ~ "type-func_suffix-bold_task-circles",
    acq == "3D_T2" ~ "type-anat_suffix-T2w_acq-wb",
    acq == "HIRES_T2" ~ "type-anat_suffix-T2w_acq-hcsf",
    acq == 'NODDI' ~ 'type-dwi_suffix-dwi',
    acq == 'T2W_FLAIR_2D' ~ 'type-anat_suffix-FLAIR',
    acq == 'tgse_pcasl_ve11c_Multidelay' ~ 'type-perf_suffix-asl',
    acq == 'fmri_task-circles_fmap_dir-pa' ~ 'type-fmap_suffix-epi_acq-circles_dir-pa',
    acq == 'fmri_task-circles_fmap_dir-ap' ~ 'type-fmap_suffix-epi_acq-circles_dir-ap',
    acq == 'NODDI_fmap_dir-pa' ~ 'type-fmap_suffix-epi_acq-dwi-noddi_dir-pa',
    acq == 'tgse_pcasl_ve11c_Multidelay_fmap_dir-ap' ~ 'type-fmap_suffix-epi_acq-perf-asl_dir-ap',
    acq == 'tgse_pcasl_ve11c_Multidelay_fmap_dir-pa' ~ 'type-fmap_suffix-epi_acq-perf-asl_dir-pa',
    acq == 'SWI_e1' ~ 'type-swi_suffix-gre_part-mag_echo-1',
    acq == 'SWI_e2' ~ 'type-swi_suffix-gre_part-mag_echo-2',
    acq == 'SWI_e3' ~ 'type-swi_suffix-gre_part-mag_echo-3',
    acq == 'SWI_e4' ~ 'type-swi_suffix-gre_part-mag_echo-4',
    acq == 'SWI_e5' ~ 'type-swi_suffix-gre_part-mag_echo-5',
    acq == 'SWI_e6' ~ 'type-swi_suffix-gre_part-mag_echo-6',
    acq == 'SWI_e7' ~ 'type-swi_suffix-gre_part-mag_echo-7',
    acq == 'SWI_e8' ~ 'type-swi_suffix-gre_part-mag_echo-8',
    acq == 'SWI_e1_ph' ~ 'type-swi_suffix-gre_part-phase_echo-1',
    acq == 'SWI_e2_ph' ~ 'type-swi_suffix-gre_part-phase_echo-2',
    acq == 'SWI_e3_ph' ~ 'type-swi_suffix-gre_part-phase_echo-3',
    acq == 'SWI_e4_ph' ~ 'type-swi_suffix-gre_part-phase_echo-4',
    acq == 'SWI_e5_ph' ~ 'type-swi_suffix-gre_part-phase_echo-5',
    acq == 'SWI_e6_ph' ~ 'type-swi_suffix-gre_part-phase_echo-6',
    acq == 'SWI_e7_ph' ~ 'type-swi_suffix-gre_part-phase_echo-7',
    acq == 'SWI_e8_ph' ~ 'type-swi_suffix-gre_part-phase_echo-8',
    acq == 'B1Map_TURBOFLASH' ~ 'type-anat_suffix-TB1map',
    acq == 'B1Map_TURBOFLASH_UP2mm' ~ 'type-anat_suffix-TB1map_acq-up-2mm',
    TRUE ~ acq
  )
  
  out_path <- glue("{out_dir}/{out_file}.csv")
  cat(out_path, '\n')
  
  # ------------------------------------------------------------------------------
  # check paths
  # ------------------------------------------------------------------------------
  for (i in seq_along(in_paths)) {
    if (length(in_paths[[i]]) == 0) {
      stop(glue("no files found for {names(in_paths)[i]}"))
    }
  }
  
  # ------------------------------------------------------------------------------
  # fsl's fslhd
  # ------------------------------------------------------------------------------
  # read
  data_fslhd <- lapply(in_paths[['fslhd']], read.csv)
  df_fslhd <- abind(data_fslhd, along = 1) %>%
    as.data.frame() 
  
  df_fslhd <- df_fslhd %>%
    separate('descrip', into = c('te', 'time', 'phase', 'mb'), remove = FALSE, sep = ';') %>%
    mutate(te = str_remove(te, "TE="),
           time = str_remove(time, "Time="),
           phase = str_remove(phase, 'phase='),
           mb = str_remove(mb, 'mb='),
           acq = lapply(in_paths[['fslhd']], function(x) { get_value_from_path(x, 'acq') }) %>% unlist()) %>%
    select(sub, ses, acq, everything())
  
  vars_num_fslhd <- colnames(df_fslhd) %>%
    str_subset(paste0(vars_str_fslhd_all, collapse = '|'), negate = TRUE)
  
  
  df_fslhd[, vars_num_fslhd] <- apply(df_fslhd[, vars_num_fslhd], 2, as.numeric)
  as_tibble(df_fslhd)
  # idx <- names(which(apply(df_fslhd, 2, function(x) {
  #   is.na(x) %>% sum()
  # }) > 0))
  # df_fslhd[, c('descrip', idx)]
  
  # ------------------------------------------------------------------------------
  # dcm2niix's bids json (converted to csv)
  # ------------------------------------------------------------------------------
  
  data_bids <- lapply(in_paths[['bids']], read.csv)
  
  df_temp <- janitor::compare_df_cols(data_bids)
  
  df_bids <- data.frame(matrix(NA, nrow = length(data_bids), ncol = nrow(df_temp)), stringsAsFactors = FALSE)
  colnames(df_bids) <- df_temp$column_name
  
  for (i in 1:length(data_bids)) {
    cat(i, '\n')
    temp_vars_str <- colnames(data_bids[[i]]) %>% str_subset(paste0(vars_str_bids_all, collapse = '|'))
    temp_vars_num <- colnames(data_bids[[i]]) %>% str_subset(paste0(vars_str_bids_all, collapse = '|'), negate = TRUE)
    # df_bids[i, colnames(data_bids[[i]])] <- data_bids[[i]]
    df_bids[i, temp_vars_str] <- apply(data_bids[[i]][, temp_vars_str], 2, as.character)
    df_bids[i, temp_vars_num] <- apply(data_bids[[i]][, temp_vars_num], 2, as.numeric)
  }
  
  # df_bids <- abind(data_bids, along = 1) %>%
  #   as.data.frame()
  df_bids <- df_bids %>%
    mutate(path = basename(in_paths[['bids']])) %>%
    rowwise() %>%
    mutate(sub = get_sub_from_path(path),
           ses = get_ses_from_path(path)) %>%
    ungroup() %>%
    select(sub, ses, everything(), -path) %>%
    mutate(sub = as.character(sub),
           ses = as.character(as.numeric(ses)),
           acq = unlist(lapply(in_paths[['bids']], function(x) { get_value_from_path(x, 'acq') }))) %>%
    select(sub, ses, acq, everything())
  
  vars_str_bids <- colnames(df_bids) %>%
    str_subset(paste0(vars_str_bids_all, collapse = '|'))
  vars_num_bids <- colnames(df_bids) %>%
    str_subset(paste0(vars_str_bids, collapse = '|'), negate = TRUE)
  
  df_bids[, vars_str_bids]
  df_bids[, vars_num_bids] <- apply(df_bids[, vars_num_bids], 2, as.numeric)
  
  head(df_bids)
  # idx <- names(which(apply(df_bids[, vars_num_bids], 2, function(x) {
  #   is.na(x) %>% sum()
  # }) > 0))
  # 
  # df_bids[, idx]

  # ------------------------------------------------------------------------------
  # descriptive stats
  # ------------------------------------------------------------------------------
  data_desc_stats <- lapply(in_paths[['desc_stats']], read.csv)
  df_desc_stats <- abind(data_desc_stats, along = 1) %>%
    as.data.frame()
    # %>%
    #mutate(acq = lapply(in_paths[['desc_stats']], function(x) { get_value_from_path(x, 'acq') }) %>% unlist())
  
  vars_num_desc_stats <- colnames(df_desc_stats) %>%
    str_subset(paste0(vars_str_descriptive_stats, collapse = '|'), negate = TRUE)
  
  df_desc_stats[, vars_num_desc_stats] <- apply(df_desc_stats[, vars_num_desc_stats], 2, as.numeric)
  head(df_desc_stats)

  # ------------------------------------------------------------------------------
  # combine and save
  # ------------------------------------------------------------------------------
  
  df <- full_join(df_fslhd, df_bids, by = c('sub', 'ses', 'acq')) %>%
    full_join(., df_desc_stats, by = c('sub', 'ses'))
  head(df)

  df <- df %>%
    filter(!str_detect(ImageType, 'DERIVED')) %>%
    filter(!str_detect(SeriesDescription, 'mIP|SWI'))

  if (str_detect(acq, 'B1Map')) {
    df_anat <- df %>%
      filter(ImageComments == 'anatomical image') 
    out_anat <- out_path %>% str_replace('\\.csv', '_part-anat\\.csv')
    write.csv(df_anat, out_anat, row.names = F)
    df_fam <- df %>%
      filter(ImageComments == 'flip angle map')
    out_fam <- out_path %>% str_replace('\\.csv', '_part-fam\\.csv')
    write.csv(df_fam, out_fam, row.names = F)
  } else {
    write.csv(df, out_path, row.names = F)
  }
  
  
}
