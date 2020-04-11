source('scripts/main_pkgs.R')

# FLUNET daily observations are
# If the percentage of daily good quality gap-filled data is less than `perc_valid`,
# the corresponding values will be set as invalid.

# tier2 has been remove; only 166 files in the current input directory
files <- dir("G:/Github/data/flux/fluxnet212_raw/raw/SUBSET/tier1",
    recursive = T, pattern = "*.SUBSET_DD_*.", full.names = T) %>%
    { set_names(., substr(basename(.), 5, 5+5)) }

# check file and station order first
uniqs <- match(names(files), st_flux166$site) %>% diff() %>% unique()
if (length(uniqs) != 1) stop("Check file order please!")

lst <- map(files, fread, na.strings = "-9999") #-9999 has been replaced with na

# lst2 (after tidy)
lst2 <- foreach(d = lst, lat = st_flux166$lat, i = icount()) %do% {
    tidy_daily(d, lat, minValidPerc = 0.8)
}

df <- melt_list(lst2, 'site')
df$YYYY <- year(df$date)

# also need to remove leapyear 2-29; why?
file_official_dd = 'OUTPUT/fluxsites166_official_dd.csv'
fwrite(df, file_official_dd)
