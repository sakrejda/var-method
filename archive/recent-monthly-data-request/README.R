ordered_contexts <- c(
  'project::root',
  'language::R-base',
  'language::R-spatial',
  'language::R-modeling',
  'language::R-parallel',
  'language::R-data',
  'files::thailand-spatial',
  'database::thailand',
  'project::predictor-province-mixture-reporting-dtv'
)

source("../../dengue-context/get-context.R")
source("auxiliary-functions.R")

stan_data <- readRDS(file=file.path(context[['input']],paste0(context[['model-name']],'.rds')))
data <- readRDS(file=file.path(context[['input']],paste0(context[['model-name']],'-data-delay.rds')))
side_data <- readRDS(file=file.path(context[['input']],paste0(context[['model-name']],'-side-data.rds')))

coded_province_count_data <- readRDS(
  file=file.path(context[['processed-input']],
    paste0(context[['model-name']], '-province-count-data.rds')))

matched_sample_dir <-
  file.path(context[['output']],'..','model-province-mixture-reporting-dtv') %>% 
  normalizePath()

matched_sample_files <- dir(
  path=matched_sample_dir,
  pattern='^model-province-mixture-reporting-dtv.*[123456789]-output.csv$',
  full.names=TRUE)

samples <- list()
for (f in matched_sample_files) {
  s <- read.csv(f, comment.char='#')
  samples[[f]] <- list()
  parameters <- stan_pull_parameter_names(s)
  for (p in parameters) {
    samples[[f]][[p]] <- stan_pull_parameter_array(s,p)
  }
}

ss <- list()
for (p in parameters) {
  ss[[p]] <- list()
  for (s in matched_sample_files) {
    ss[[p]][[s]] <- samples[[s]][[p]]  
  }
  ss[[p]] <- do.call(what=abind::abind, args=c(ss[[p]], along=1))
}
samples <- ss; rm(ss)




