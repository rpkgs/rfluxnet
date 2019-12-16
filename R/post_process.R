## 2. tidy the generated daily fluxsites
#' @importFrom data.table year month
#' @importFrom lubridate ymd
merge_daily <- function(OUTDIR){
    files_dd <- dir(OUTDIR, full.names = T, pattern = "*.csv$")

    # check station and filename order
    diff_order = match(st_flux166$site, substr(basename(files_dd), 5, 10)) %>% diff() %>% unique
    if (length(diff_order) == 1) {
        xlst <- mlply(data.frame(file = files_dd, lat = st_flux166$lat, stringsAsFactors = F),
            add_growing, .progress = "text")
        names(xlst) <- st_flux166$site
        df <- melt_list(xlst, 'site')
        df$YYYY <- year(df$date)
        return(df)
    } else {
        warning("file order is not consistent!")
    }
}

rm_tier2_df <- function(df){
    # remove site-years of tier2 ----------------------------------------------
    sites <- c('AU-ASM' ,'AU-TTE' ,'AU-Wom' ,'CZ-BK1' ,'CZ-BK2' ,'FR-Gri' ,'NL-Loo' ,'US-Prr' ,'ZA-Kru')
    years <- c(2014, 2014, 2013, 2009, 2007, 2014, 2014, 2014, 2011)
    expr  <- sprintf('(site == "%s" & YYYY >= %s)', sites, years) %>% paste(collapse = " | \n")

    I_del <- eval(parse(text = expr), envir = df) %>% which()
    # I_del <- with(df, (site == "AU-ASM" & year >= 2014) |
    #                (site == "AU-TTE" & year >= 2014) |
    #                (site == "AU-WOM" & year >= 2013) |
    #                (site == "CZ-BK1" & year >= 2009) |
    #                (site == "CZ-BK2" & year >= 2007) |
    #                (site == "FR-GRI" & year >= 2014) |
    #                (site == "NL-LOO" & year >= 2014) |
    #                (site == "US-PRR" & year >= 2014) |
    #                (site == "ZA-KRU" & year >= 2011))
    # info = df[site %in% sites, .(end = max(date)), .(site)]
    if (length(I_del) != 0) {
        df <- df[-I_del, 1:(ncol(df) - 1)]
    } else {
        message("no tier2 data")
    }
    df
}

fix_neg <- function(df){
    vars_noneg = c("GPP_NT", "LE", "LE_CORR")
    df[, (vars_noneg) := lapply(.SD, clamp_min, value = 0), .SDcols = vars_noneg]
    df
}

#' add year, month, growing season information
#' @export
add_growing <- function(file, lat){
    x <- fread(file)

    date <- ymd(x$date)
    ## 1. add Year, MM, growing
    year  <- year(date)
    month <- month(date)

    # I_summer <- month %in% 6:8
    # I_winter <- month %in% c(12, 1, 2)
    if (lat < 0){
        year <- year - 1 + (month >= 7)
        growing <- month %in% 3:10
    }else{
        growing <- month <= 4 | month >= 9
    }
    growing <- as.numeric(growing)
    cbind(date, year, month, growing, x[, 2:ncol(x)])
}
