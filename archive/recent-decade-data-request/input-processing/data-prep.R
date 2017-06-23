library(rstan)

data[['row']] <- 1:nrow(data)
  
saveRDS(object=data, file=file.path(context[['input']],paste0(context[['model-name']],'-data-delay.rds')))

side_data <- with(data=data, expr = list(
  province_index_map = unique(data[,c('province_index','province')]) %>% arrange(province_index)
))

saveRDS(object=side_data, file=file.path(context[['input']],paste0(context[['model-name']],'-side-data.rds')))


saveRDS(object=coded_subdistrict_count_data,
  file=file.path(context[['processed-input']],
  paste0(context[['model-name']], '-subdistrict-count-data.rds')))
saveRDS(object=coded_district_count_data,
  file=file.path(context[['processed-input']],
  paste0(context[['model-name']], '-district-count-data.rds')))
saveRDS(object=coded_province_count_data,
  file=file.path(context[['processed-input']],
  paste0(context[['model-name']], '-province-count-data.rds')))
saveRDS(object=coded_province_yearly_count_data,
  file=file.path(context[['processed-input']],
  paste0(context[['model-name']], '-province-yearly-count-data.rds')))

