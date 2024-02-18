#' Tidy FLUXNET daily-scale dataset.
#'
#' @param d Data.table of fluxnet tier1 daily observations. Fluxnet daily file is
#' in the format of `FLX_{site}_FLUXNET2015_SUBSET_DD_{year_start}-{year_end}_2-3.csv`.
#' @param lat Double, latitude of this site.
#' @param minValidPerc Double, in the range of 0-1. If the percentage of measured and
#' good quality gap-filled data is less than `minValidPerc`, NA value will be replaced.
#'
#' @importFrom lubridate ymd
#' @export
tidy_daily <- function(dt, lat, minValidPerc = 0.8) {
  date <- ymd(as.character(dt$TIMESTAMP))
  n <- length(date)

  # add newdate to make sure its complete year for North and South Hemisphere
  if (lat < 0) {
    date_begin <- ymd(sprintf("%d-%d-%d", year(date[1]) - 1, 7, 1))
    date_end <- ymd(sprintf("%d-%d-%d", year(date[n]) + 1, 6, 30))
  } else {
    date_begin <- ymd(sprintf("%d-%d-%d", year(date[1]), 1, 1))
    date_end <- ymd(sprintf("%d-%d-%d", year(date[n]), 12, 31))
  }
  newdate <- seq.Date(date_begin, date_end, by = "day")

  year <- year(newdate)
  month <- month(newdate)

  ## 1. add growing
  # North Hemisphere, growing: 4-10 (Wang Xuhui, 2011, PNAS)
  # South Hemisphere, growing: 10, 11, 12, 1, 2, 3, 4
  # I_summer <- month %in% 6:8
  # I_winter <- month %in% c(12, 1, 2)
  if (lat < 0) {
    growing <- month <= 4 | month >= 10
    year <- year - 1 + (month >= 7)
  } else {
    growing <- month %in% 4:10
  }
  growing <- as.numeric(growing)

  # 2. select valid obs
  # df <- suppressMessages(read.csv(unz(file, file_csv)))
  Id_na <- which(is.na(match(vars_all, colnames(dt))))
  # df[, vars_all[Id_na]] <- NA #this step must be data.frame variables
  if (length(Id_na) > 0) dt[, (vars_all[Id_na]) := NA]

  x_val <- dt[, vars_val, with = F]
  x_qc <- dt[, vars_QC, with = F]
  x2 <- x_val
  x2[x_qc < minValidPerc] <- NA
  # x_val[x_qc  < minValidPerc] <- NA

  I <- match(newdate, date)
  date <- newdate
  # rename
  setnames(x_val, gsub("_F$|_F_MDS$|_F_MDS_1|_VUT_REF", "", names(x_val)) %>%
    gsub("NETRAD", "Rn", .))
  setnames(x_qc, gsub("_F$|_F_MDS$|_F_MDS_1|_VUT_REF", "", names(x_val)) %>%
    gsub("NETRAD", "Rn", .) %>%
    paste0("_QC"))

  d_meta <- data.table(date, year, YYYY = year(date), month, growing)
  d <- cbind(d_meta, x2[I, ])
  d0 <- cbind(d_meta, x_val[I, ], x_qc[I, ])
  # browser()
  # dnew
  list(data = d, data0 = d0)
  # 3. remove all na variables in tail and head
  # flag <- rowSums(is.na(as.matrix(x_val))) < ncol(x_val)
  #
  # ## remove small segments in values
  # r <- rle(flag)
  # # print(r$lengths[r$values])
  # r$values[r$values][r$lengths[r$values] <= 3]  <- FALSE
  # flag <- inverse.rle(r)
  #
  # I <- which(flag) %>% {first(.):last(.)}
  # df[I, ] #quickly return
}
