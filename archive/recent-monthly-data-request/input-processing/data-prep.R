library(rstan)

data[['row']] <- 1:nrow(data)
  
saveRDS(object=data, file=file.path(context[['input']],paste0(context[['model-name']],'-data-delay.rds')))

side_data <- with(data=data, expr = list(
  province_index_map = unique(data[,c('province_index','province')]) %>% arrange(province_index)
))

saveRDS(object=side_data, file=file.path(context[['input']],paste0(context[['model-name']],'-side-data.rds')))

saveRDS(object=monthly_2013_count_data,
  file=file.path(context[['processed-input']],
  paste0(context[['model-name']], '-monthly-2013-count-data.rds')))

