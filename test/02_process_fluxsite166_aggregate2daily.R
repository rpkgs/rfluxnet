source('test/main_pkgs.R')
################################################################################

files <- dir("INPUT/FULLSET_tier1_patch_applied/", recursive = T, pattern = "*.FULLSET_[HR|HH]_*.", full.names = T)
outdir       <- "OUTPUT"
# tmp <- lapply(files, get_daytime, outdir = "Z:/fluxsite212/daily/")
# x <- get_daytime(files[2], outdir = "Z:/fluxsite212/daily/")

lst_vars <- map(files, ~fread(.x, nrow = 1) %>% colnames)
vars <- unlist(lst_vars) %>% unique()

process_fluxnet <- function(files, outdir = "OUTPUT", minValidPerc = 0.8){
    # file = files[1]
    outdir_temp = paste0(outdir, "/temp")

    for (i in seq_along(files)){
        Ipaper::runningId(i)
        tryCatch(get_daytime(files[i], outdir = outdir_temp, overwrite = TRUE, minValidPerc = minValidPerc))
        # warning = function(w){
        #     message(i, w$message, "\n")
        # })
    }
    df  <- merge_daily(outdir_temp)
    df2 <- rm_tier2_df(df) %>% fix_neg()
    outfile = sprintf("fluxsites166_FULLSET_daily_v%s (%d%%).csv", format(Sys.Date(), "%Y%m%d"), minValidPerc*100)
    fwrite(df2, outfile)

    ## aggregated into 8day
    df2 %<>% add_dn(days = 8)
    vars_comm = c("site", "date", "YYYY", "year", "month", "doy", "d8")
    vars_aggr = colnames(df2) %>% setdiff(vars_comm)
    df_d8 <- df2[, lapply(.SD, mean, na.rm = F), .(site, year, d8), .SDcols = vars_aggr]

    outfile_8d = sprintf("fluxsites166_FULLSET_8-day_v%s (%d%%).csv", format(Sys.Date(), "%Y%m%d"), minValidPerc*100)
    fwrite(df_d8, outfile_8d)
}

process_fluxnet(files, outdir, minValidPerc = 0.8)

# org <- fread("Z:/dailyforing_93sites/INPUTS/PML_inputs_8d_dynamicLC_006_CO2_v3.csv")
# result <- merge(org, df_d8, c("site", "year", "dn"))
# # org[, `:=`(GPP_DT = NULL, GPP_NT = NULL, LE = NULL)]
# fwrite(result, "PMLV2_INPUTS_flux112_20180309_v2.csv")
