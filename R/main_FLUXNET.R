#' @import data.table magrittr fasttime
NULL
# lubridate

# Update 13 Sep, 2018
# -------------------
# It's the 24-hour data used to aggregate daily meteorological and biological
# variables, not daytime. Daytime was only used to get day time hour (dhour).
#
# Update 30 Nov, 2017; Dongdong Kong
#   Fixed Soil heat flux G error, G can have negative values.
#   NETRAD also could is negative; unchaneged due to only daytime flux considered
#
# If daily validate obs < 50%, then set it and NA. This restriction has been writen in

check_file <- function(file, outdir, postfix = "_rfluxnet") {
  outfile <- sprintf("%s/%s%s%s", outdir, gsub(".csv", "", basename(file)), postfix, ".csv")
  outfile
}

# get_dailyData <- function(dir, type = c("HH", "HR")){
get_hourly_csv <- function(file_csv, outdir = "data/hourly/", overwrite = FALSE) {
  outfile <- check_file(file_csv, outdir)
  if (file.exists(outfile) && overwrite == FALSE) {
    return()
  }

  tryCatch(
    {
      dt <- fread(file_csv, sep = ",", header = T, showProgress = F, verbose = F) # %>% as.data.frame()
      xt <- tidy_hourly(dt)
      fwrite(data.table(xt), file = outfile)
    },
    error = function(e) message(sprintf("%s", e))
  )
}

# manipulate hourly data after the processing of get_hourly
get_daytime_csv <- function(file_csv, outdir = "data/daytime/", overwrite = FALSE) {
  outfile <- check_file(file_csv, outdir)
  if (file.exists(outfile) && overwrite == FALSE) {
    return()
  }

  # varnames = Output_variables_FLUXNET2015_FULLSET$Fluxnet_variable
  dt <- fread(file_csv, sep = ",")
  x_daily <- tidy_daytime(dt)
  fwrite(data.table(x_daily), file = outfile)
  # return(x_daily)
}

# combine 2 steps: tidy hourly data and aggregate into daytime
get_daytime <- function(
    file_csv, outdir = "data/daytime/", overwrite = FALSE,
    minValidPerc = 0.8) {
  outfile <- check_file(file_csv, outdir)
  if (file.exists(outfile) && overwrite == FALSE) {
    return()
  }

  dt <- fread(file_csv, sep = ",", header = T, showProgress = F, verbose = F) # %>% as.data.frame()
  # dt <- fread(file_csv, sep = ",")
  xt <- tidy_hourly(dt) # hourly data
  x_daily <- tidy_daytime(xt, minValidPerc = minValidPerc) # daytime data
  fwrite(data.table(x_daily), file = outfile)
}
