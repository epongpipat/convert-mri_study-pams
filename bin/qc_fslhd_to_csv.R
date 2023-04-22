# ------------------------------------------------------------------------------
# options
# ------------------------------------------------------------------------------
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser()
parser$add_argument("-i", "--in_path", help="path to tsv",required = TRUE)
parser$add_argument("-o", "--out_path", help="path to csv (default: <in_path>.csv)",required = FALSE, default = NULL)
parser$add_argument("--overwrite", help="flag to overwrite <0|1> (default: 0)", default = 0, dest = "overwrite")
args <- parser$parse_args()

# ------------------------------------------------------------------------------
# pkgs
# ------------------------------------------------------------------------------
cat('- pkgs\n')
pkgs <- c('glue', 'readr', 'stringr', 'dplyr', 'janitor',
          'rHelperKennedyRodrigue')
xfun::pkg_attach2(pkgs, message = F)

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
cat('- check paths\n')
in_path <- args$in_path

if (is.null(args$out_path)) {
    out_path <- str_replace(in_path, "\\.tsv", "\\.csv")
} else {
    out_path <- args$out_path
}

overwrite <- args$overwrite
if (file.exists(out_path) & overwrite == 0) {
    stop(glue("error: file already exists and overwrite set to 0 {out_path}"))
} else if (file.exists(out_path) & overwrite == 1) {
    unlink(out_path)
    warning(glue("warning: file already exists and overwrite set to 1 {out_path}"))
}

# ------------------------------------------------------------------------------
# functionsin
# ------------------------------------------------------------------------------
# cat('- functions\n')
# get_sub_from_path <- function(path) {
#   sub <- path %>%
#     str_split('/') %>%
#     unlist() %>%
#     str_subset('sub-') %>%
#     str_split('_') %>%
#     unlist() %>%
#     str_subset('sub-') %>%
#     str_remove('sub-')
#   return(sub)
# }

# get_ses_from_path <- function(path) {
#   ses <- path %>%
#     str_split('/') %>%
#     unlist() %>%
#     str_split('_') %>%
#     unlist() %>%
#     str_subset('ses-') %>%
#     .[[1]] %>%
#     str_split('-') %>%
#     unlist() %>%
#     .[[2]]
#   return(ses)
# }

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
cat('- read\n')
cat(glue("in_path: {in_path}"), '\n')
df <- read_tsv(in_path, show_col_types = FALSE)
head(df)
cat('- transpose\n')
df <- as.data.frame(df)
df <- t(df) %>%
    as.data.frame()
colnames(df) <- as.character(unlist(df[1,]))
df <- df[2,]

cat('- clean\n')
df <- df %>%
    clean_names() %>%
    mutate(sub = get_sub_from_path(in_path), 
           ses = get_ses_from_path(in_path)) %>%
    select(sub, ses, everything())

cat('- split qto_xyz and sto_xyz\n')
for (i in 1:4) {
  temp_qto <- df[1, glue("qto_xyz_{i}")] %>% str_split(., ' ') %>% unlist() %>% as.numeric()
  temp_sto <- df[1, glue("sto_xyz_{i}")] %>% str_split(., ' ') %>% unlist() %>% as.numeric()
  for (j in 1:4) {
    cmd <- glue("df$qto_xyz_{i}_{j} <- temp_qto[{j}]")
    eval(parse(text = cmd))
    cmd <- glue("df$sto_xyz_{i}_{j} <- temp_sto[{j}]")
    eval(parse(text = cmd))
  }
  df <- df %>%
    select(-c(glue("qto_xyz_{i}"), glue("sto_xyz_{i}")))
}

cat('- write\n')
write.csv(df, out_path, row.names = F)
