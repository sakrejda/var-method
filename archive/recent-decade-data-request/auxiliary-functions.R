
stan_column_names_to_parameter_names <- function(s) {
  o <- sub(pattern='(^[a-zA-Z_]+)\\..*', 
    replacement='\\1', x=s)
  return(o)
}

stan_column_names_to_index_strings <- function(s) {
  o <- sub(pattern='(^[a-zA-Z_0-9]+)(\\.*.*)', 
    replacement='\\2', x=s)
  return(o)
}

stan_column_names_to_ndim <- function(s) {
  s <- stan_column_names_to_index_strings(s)
  nd <- gsub(pattern='[^\\.]', replacement='', x=s) %>% nchar 
  return(nd)
}

#' Here 's' must be column names form one parameter.
stan_column_names_to_dim_sizes <- function(s) {
  pn <- stan_column_names_to_parameter_names(s) %>% unique
  if (length(pn) != 1) 
    stop("'s' must only contain column names from a single parameter.")
  ivs <- stan_column_names_to_index_strings(s) %>% 
    strsplit(split='\\.') 
  nd <- stan_column_names_to_ndim(s) %>% unique
  if (nd == 0)
    return(0)
  o <- vector(mode='numeric', length=nd)
  for ( i in 1:nd ) {
    o[i] <- sapply(ivs,`[`,i+1) %>% as.numeric %>% max
  }
  return(o)
}

stan_pull_parameter_names <- function(sample) {
  cn <- colnames(sample)
  pn <- stan_column_names_to_parameter_names(cn) %>% unique
  return(pn)
}

stan_pull_column_names_by_parameter_name <- function(sample, name) {
  cn <- colnames(sample)
  o <- cn[grepl(pattern=paste0('^',name,'\\.'),x=cn)]
  if (isTRUE(length(o) == 0))
    o <- name
  return(o)
}

stan_pull_parameter_dimensions <- function(sample) {
  cn <- colnames(sample)
  parameter_names <- stan_pull_parameter_names(sample)
  o <- list()
  for (name in parameter_names) {
    o[[name]] <- stan_pull_column_names_by_parameter_name(sample,name)
    if (isTRUE(all(o[[name]] == name)))
      o[[name]] <- numeric(0)
    else {
      o[[name]] <- stan_column_names_to_dim_sizes(o[[name]])
    }
  }
  return(o)
}

stan_pull_parameter_array <- function(sample, name, dimnames=NULL) {
  n_iter <- nrow(sample)
  cn <- stan_pull_column_names_by_parameter_name(sample,name)
  nd <- stan_column_names_to_ndim(cn)
  dims <- stan_pull_parameter_dimensions(sample)[[name]]
  if (isTRUE(length(dims) == 0)) {
    a <- array(data=sample[[name]], dim=n_iter, dimnames=list(iter=1:n_iter))
  }
  good_dimnames <- isTRUE(length(dimnames) == length(dims))
  if (good_dimnames) {
    dimnames <- c(list(n_iter=1:n_iter), dimnames)
  } else {
    dimnames <- list(n_iter=1:n_iter)
    for (i in 1:length(dims)) {
      dimnames <- c(dimnames, list(DIM=1:dims[i]))
      names(dimnames)[names(dimnames) == 'DIM'] <- letters[i+9]
    }
  }
  flat_sample <- unlist(sample[cn])
  a <- array(data=flat_sample, dim=c(n_iter, dims), dimnames=dimnames) 
  return(a)
}

stan_pull_parameter_df <- function(sample, name) {
  cn <- stan_pull_column_names_by_parameter_name(sample, name)
  o <- sample[cn]
  return(o)
}






date_to_subyear_interval_factory <- function(map, leap_year_map=map) {

  # Remember these:
  regular_year_map = map; leap_year_map = leap_year_map

  # Function def:
  date_to_subyear_interval <- function(date) {
    lyi  <- sapply( leap_year(date), isTRUE)
    nlyi <- sapply(!leap_year(date), isTRUE)
    o <- vector(mode='numeric', length=length(date))
    o[ is.na(date)] <- NA
    o[!is.na(date)] <- yday(date[!is.na(date)])
    o[lyi] <- leap_year_map[o[lyi],'biweek']
    o[nlyi] <- regular_year_map[o[nlyi],'biweek']
    if (any(o > 26 | o < 1)) stop()
    return(o)
  }

  return(date_to_subyear_interval)
}


dat <- data.frame(biweeks = 1:26, num_days = 14)
dat[26,'num_days'] <- 15
dat[['num_days_leap_year']] <- dat[['num_days']]
dat[5,'num_days_leap_year'] <- 15

no_leap_year <- data.frame(
  julian_day = 1:365,
  biweek = rep(x=dat[['biweeks']], times=dat[['num_days']])
)

leap_year <- data.frame(
  julian_day = 1:366,
  biweek = rep(x=dat[['biweeks']], times=dat[['num_days_leap_year']])
)

date_to_biweek <- date_to_subyear_interval_factory(
  map = no_leap_year, leap_year_map = leap_year)

