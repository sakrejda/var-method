
fields <- c(
  'province', 'geocode', 
  'geocode_province', 'geocode_district', 'geocode_subdistrict',
  'date_sick', 'delivery_date', 'delivery_file'
) %>% paste(collapse=', ')

stmt <- paste0(
  "SELECT ", fields, " FROM ",
  "unique_case_data ",
  "WHERE disease = '26' AND date_sick >= '2004-01-01' AND date_sick < '2014-01-01';")

data <- dbGetQuery(shared$link$conn, stmt)

## Add fields:
data[['province']] <- factor(data[['province']])

## Geocode fields are sometimes NA (even when original data is not NA,
## as there is filtering against an outside list).  RE-code these to -1
## -1 will get an index (NA would not) and special treatment in 
## modeling
data <- data %>% mutate(
  geocode_province = ifelse(is.na(geocode_province),-1,geocode_province),
  geocode_district = ifelse(is.na(geocode_district),-1,geocode_district),
  geocode_subdistrict = ifelse(is.na(geocode_subdistrict),-1,geocode_subdistrict)
)


data <- data %>% mutate(
  time_sick = as.numeric(difftime(date_sick, min(date_sick), tz='EST', units='days')),
  day_of_year_sick = yday(date_sick),
  week_sick = week(date_sick),
  biweek_sick = date_to_biweek(date_sick),
  month_sick = month(date_sick),
  year_sick = year(date_sick),
  province_index = as.numeric(province),
  geocode_province = as.numeric(geocode_province),
  geocode_district = as.numeric(geocode_district),
  geocode_subdistrict = as.numeric(geocode_subdistrict),
  geocode_province_index = as.numeric(as.factor(geocode_province)),
  geocode_district_index = as.numeric(as.factor(geocode_district)),
  geocode_subdistrict_index = as.numeric(as.factor(geocode_subdistrict))
)

subdistrict_count_data <- data %>% group_by(
    geocode_province, geocode_province_index,
    geocode_district, geocode_district_index,
    geocode_subdistrict, geocode_subdistrict_index, 
    year_sick, biweek_sick
  ) %>% summarise(
    mean_date_sick = mean(date_sick),
    count=n()
  ) %>% arrange(
    geocode_province, geocode_district, geocode_subdistrict, year_sick, biweek_sick
  ) %>% ungroup()

uncoded_subdistrict_count_data <- subdistrict_count_data %>% 
  filter(geocode_province == -1 | geocode_district == -1 | geocode_subdistrict == -1) %>% 
  group_by(year_sick) %>% summarise(count=sum(count))

coded_subdistrict_count_data <- subdistrict_count_data %>%
  filter(geocode_province != -1 & geocode_district != -1 & geocode_subdistrict != -1) 


district_count_data <- data %>% group_by(
    geocode_province, geocode_province_index,
    geocode_district, geocode_district_index,
    year_sick, biweek_sick
  ) %>% summarise(
    mean_date_sick = mean(date_sick),
    count=n()
  ) %>% arrange(
    geocode_province, geocode_district, year_sick, biweek_sick
  ) %>% ungroup()

uncoded_district_count_data <- district_count_data %>% 
  filter(geocode_province == -1 | geocode_district == -1) %>% 
  group_by(year_sick) %>% summarise(count=sum(count))

coded_district_count_data <- district_count_data %>%
  filter(geocode_province != -1 & geocode_district != -1) 


province_count_data <- data %>% group_by(
    geocode_province, geocode_province_index,
    year_sick, biweek_sick
  ) %>% summarise(
    mean_date_sick = mean(date_sick), count=n()
  ) %>% arrange(
    geocode_province, year_sick, biweek_sick
  ) %>% ungroup()

uncoded_province_count_data <- province_count_data %>% 
  filter(geocode_province == -1) %>% 
  group_by(year_sick) %>% summarise(count=sum(count))

coded_province_count_data <- province_count_data %>%
  filter(geocode_province != -1) 

#### province NOT geocode_province b/c geocode_province does not work
#### pre-mid-2008 or so. Fix that.
province_yearly_count_data <- data %>% group_by(
    province, province_index,
    year_sick
  ) %>% summarise(
    mean_date_sick = mean(date_sick), yearly_count=n()
  ) %>% arrange(
    province, year_sick 
  ) %>% ungroup()

uncoded_province_yearly_count_data <- province_yearly_count_data %>% 
  filter(province == -1) %>% 
  group_by(year_sick) %>% summarise(yearly_count=sum(yearly_count))

coded_province_yearly_count_data <- province_yearly_count_data %>%
  filter(province != -1) 





