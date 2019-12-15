source('test/main_pkgs.R')
################################################################################

files <- dir("INPUT/FULLSET_tier1_patch_applied/", recursive = T, pattern = "*.FULLSET_[HR|HH]_*.", full.names = T)
outdir       <- "OUTPUT"
# tmp <- lapply(files, get_daytime, outdir = "Z:/fluxsite212/daily/")
# x <- get_daytime(files[2], outdir = "Z:/fluxsite212/daily/")

file = files[1]

for (i in seq_along(files)){
    Ipaper::runningId(i)
    tryCatch(get_daytime(files[i], outdir = outdir))
    # warning = function(w){
    #     message(i, w$message, "\n")
    # })
}
# get_daytime(files[1], outdir = "./")

# check station and filename order
match(stations_166$site, substr(basename(files_dd), 5, 10)) %>% diff() %>% unique

library(plyr)
# 2. tidy the generated daily fluxsites
files_dd <- dir("Z:/fluxsite212/raw/daily_v2018 (60%)/", full.names = T, pattern = "*.csv$")

# xlst <- mapply(tidy_dd, files_DD, stations_166$lat)
xlst <- mlply(data.frame(file = files_dd, lat = stations_166$lat, stringsAsFactors = F),
              tidy_dd, .progress = "text")
names(xlst) <- stations_166$site

df <- phenofit::melt_list(xlst, 'site')
df$YYYY <- year(df$date)

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
df <- df[-I_del, 1:(ncol(df) - 1)]
fwrite(df, 'Z:/fluxsite212/raw/fluxsites166_daily_v20180312 (60%).csv')

## fix ET and GPP negative values
# df  <- fread("file:///Z:/fluxsite212/raw/fluxsites166_daily_v20180309.csv")
# df$date %<>% ymd
# df$GPP_DT %<>% fix_neg
# df$GPP_NT %<>% fix_neg
# df$LE %<>% fix_neg
#
# fwrite(df, 'data/fluxsites166_daily_fixNeg_v20180309.csv')
#
# org <- fread("Z:/dailyforing_93sites/INPUTS/PML_inputs_8d_dynamicLC_006_CO2_v3.csv")
#
# # check
# fix_neg <- function(x){
#     x[x < 0] <- 0
#     return(x)
# }
# df$LE %<>% fix_neg
# # aggregated into 8day
# df_d8 <- df[, .(date, site, GPP_DT, GPP_NT, LE)]
# df_d8 %<>% add_dn(d16 = FALSE)
# names(df_d8)[8] <- "dn"
#
# df_d8 <- df_d8[, lapply(.SD, mean, na.rm = F), .(site, year, dn), .SDcols = c("GPP_NT", "GPP_DT", "LE")]
#
#
# result <- merge(org, df_d8, c("site", "year", "dn"))
# # org[, `:=`(GPP_DT = NULL, GPP_NT = NULL, LE = NULL)]
# fwrite(result, "PMLV2_INPUTS_flux112_20180309_v2.csv")
