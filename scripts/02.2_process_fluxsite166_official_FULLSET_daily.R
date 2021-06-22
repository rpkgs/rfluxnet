source('scripts/main_pkgs.R')

# FLUNET daily observations are
# If the percentage of daily good quality gap-filled data is less than `perc_valid`,
# the corresponding values will be set as invalid.

# files <- dir("INPUT/FULLSET_tier1_patch_applied/", recursive = T,
#              pattern = "*.FULLSET_DD_*.", full.names = T)

# tier2 has been remove; only 166 files in the current input directory
files <- dir("G:/Github/data/flux/fluxnet212_raw/raw/SUBSET/tier1",
    recursive = T, pattern = "*.SUBSET_DD_*.", full.names = T) %>%
    { set_names(., substr(basename(.), 5, 5+5)) }

# check file and station order first
uniqs <- match(names(files), st_flux166$site) %>% diff() %>% unique()
if (length(uniqs) != 1) stop("Check file order please!")

lst <- map(files, fread, na.strings = "-9999") #-9999 has been replaced with na

# lst2 (after tidy)
minValidPerc = 0.8
lst2 <- foreach(d = lst, lat = st_flux166$lat, i = icount()) %do% {
    tidy_daily(d, lat, minValidPerc = minValidPerc)
}

df  <- map(lst2, "data") %>% melt_list('site')
df0 <- map(lst2, "data0") %>% melt_list('site')

# also need to remove leapyear 2-29; why?
file_official_dd     = glue('OUTPUT/fluxsites166_official_SUBSET_DD_minValid{minValidPerc*100}%.csv')
file_official_dd_raw = glue('OUTPUT/fluxsites166_official_SUBSET_DD_raw.csv')
fwrite(df , file_official_dd)
fwrite(df0, file_official_dd_raw)

# st_flux212[tier1 != tier2 & tier1 == "", table(IGBP)]
d = df0 %>% subset(site == "US-ARM")
brks = c(-Inf, 0.5, 0.7, 0.8, 0.9, Inf)
ggplot(d,aes(date, GPP_DT, color = GPP_DT_QC)) +
    geom_line() +
    geom_line(aes(date, RECO_DT), color = "red")
# files <- dir("INPUT/FULLSET_tier1_patch_applied/", recursive = T, pattern = "*.FULLSET_[HR|HH]_*.", full.names = T)
saveRDS(df0, "OUTPUT/fluxsites166_official_SUBSET_DD_raw.RDS")
