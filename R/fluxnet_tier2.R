#' Move tier2 data (46 sites)
#' @export
RemoveTier2 <- function() {
    files <- dir("Z:/fluxsite212/raw/all", recursive = T, pattern = "*.SUBSET_[HR|HH]_*.", full.names = T)

    stations_166 <- fread("F:/Github/MATLAB/PML/data/flux_166.csv")
    I <- match(stations_166$site, substr(basename(files), 5, 10))
    dirs <- dirname(files)[-I]
    file.rename(dirs, paste0("Z:/fluxsite212/raw/tier2/", basename(dirs)))
    ## remove tier2

    files <- dir("Z:/fluxsite212/daily/", full.names = T, pattern = "*.csv$")
    I <- match(stations_166$site, substr(basename(files), 5, 10))
    file.remove(files[-I]) # only 166 left
    files <- files[I] %>% set_names(stations_166$site)
}
