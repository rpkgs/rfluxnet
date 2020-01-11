#' @note 
#' # 2020-01-04
#' Note that all variables except dhour, are averaged or sumed (for precipitation) 
#' in daily-scale other than daytime.
#' 
#' @importFrom lubridate fast_strptime date
#' @export
tidy_daytime <- function(dt, minValidPerc = 0.8) {
    ## 1. transform timestamp
    fmt_date   <- "%Y%m%d%H%M"
    time_begin <- as.character(dt$TIMESTAMP_START) %>% fast_strptime(fmt_date)
    time_end   <- as.character(dt$TIMESTAMP_END) %>% fast_strptime(fmt_date)

    deltaT <- unique(difftime(time_end, time_begin, units = "hours")) # for HH dt = 1/2, HR dt = 1
    # print(deltaT)

    date <- date(time_begin)
    # date_end   <- date(time_end)
    time_begin %<>% format("%H:%M") # %S
    time_end   %<>% format("%H:%M")

    vars_date <- c("date", "time_begin", "time_end") # date variables
    dt[, (vars_date) := list(date, time_begin, time_end)]
    dt[, c("TIMESTAMP_START", "TIMESTAMP_END") := NULL]

    ## 2. vars can't have negative values, have been manipulated in get_daily
    ## 3. get daily prcp
    # prcp <- dt[, .(P_F = sum(P_F, na.rm = T)), by = date] #mm into mm/day
    prcp <- dt[, .(P_F = sum_perc(P_F, minValidPerc)), by = date]
    ## 4. day light hours according to shortwave incoming radiation > 5/W/m2
    dt_dlight <- dt[SW_IN_F >= 5, ] # modified 29112017

    # dhour     <- dt_dlight[, .N, by = date]$N * deltaT  #day light hours
    dhour <- dt_dlight[, .(dhour = .N * deltaT, Tair_day = mean(TA_F, na.rm = TRUE)), by = date]

    ## changed to daytime again
    dt_dlight <- dt
    # mean of all the variables except precipitation, and date variables
    x_daily <- dt_dlight[, lapply(.SD, mean_perc, minValidPerc),
        by = date,
        .SDcols = setdiff(names(dt_dlight), c("P_F", vars_date))
    ]
    x_daily[, ":="(VPD_F = VPD_F * 0.1)] # hPa to kPa
    x_daily <- merge(dhour, x_daily, by = "date", all = T) # add dhour parameter

    # 5. Convert Carbon flux units (from umol/m2/s to g/m2/d),
    #    Only for Var = NEE, GPP, RE
    SDcols <- names(x_daily) %>% .[grep("GPP_|NEE_|RECO_", .)]

    x_daily[, (SDcols) := lapply(.SD, function(x) x <- x * 1.0368),
        .SDcols = SDcols
    ] # 12*86400/10^6 = 1.0368

    # merge precipitation into data.table and rename colnames
    x_daily %<>% merge(prcp, by = "date")
    setnames(
        x_daily, names(x_daily),
        gsub("_F$|_F_MDS$|_F_MDS_1|_VUT_REF", "", names(x_daily)) %>%
            gsub("NETRAD", "Rn", .)
    ) # rename Net Radiation
    setcolorder(x_daily, c("date", "dhour", sort(names(x_daily[, -c("date", "dhour")]))))

    # 6 check the date continuity of x_daily, If not continue, then fill NAN
    #   values in it.
    date <- x_daily$date
    vals <- diff(date)

    if (length(unique(vals)) != 1) {
        # message(sprintf("%s", basename(file_csv)))
        print(rle(as.numeric(vals)))

        dateBegin <- date[1]
        dateEnd <- date[length(date)]
        dates_new <- seq.Date(dateBegin, dateEnd, by = "day")
        days <- difftime(dateEnd, dateBegin, "days") + 1
        cols <- ncol(x_daily)
        tmp <- matrix(NA, nrow = days, ncol = cols) %>%
            set_colnames(names(x_daily))
        tmp[match(date, dates_new), ] <- as.matrix(x_daily)
        # tmp[, "date"] <- dates_new
        x_daily <- data.table(tmp)
        x_daily$date <- dates_new
        # y$date <- dates
        # print(unique(diff(as.Date(y$date))))
    }
    return(x_daily)
}
