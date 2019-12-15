source("test/main_pkgs.R")
indir       <- "G:/Github/data/flux/fluxnet212_raw/raw/FULLSET/tier1" %>% path.mnt()
indir.patch <- "G:/Github/data/flux/fluxnet212_raw/raw/FULLSET/FLUXNET2015_PATCH1/" %>% path.mnt()

# datasetversions <- map_chr(files, get_fluxnet_version_no)
files       <- dir(indir, recursive = T, pattern = "*.FULLSET_[HR|HH]_*.", full.names = T)
files.patch <- dir(indir.patch, recursive = T, pattern = "*.PATCH1_[HR|HH]_*.", full.names = T)
# filesERA <- dir(indir, recursive = T, pattern = "*.ERAI_[HR|HH]_*.", full.names = T)

# infiles <- get_fluxnet_files(in_path)
site_codes       <- map_chr(files, get_path_site_code) %>% set_names(., .)
site_codes.patch <- map_chr(files.patch, get_path_site_code)

Ind <- match(site_codes, site_codes.patch)
OUTDIR = "./OUTPUTS/FULLSET_tier1_patch_applied"

lst <- foreach(site_code = site_codes, infile = files, file.patch = files.patch[Ind], i = icount()) %do% {
    runningId(i)
    outfile = sprintf("%s/%s%s", OUTDIR, gsub(".csv", "", basename(infile)), "_patched.csv")
    if (file.exists(outfile)) return()

    d <- fread(infile)
    TIMESTAMP_START0 <- last(d$TIMESTAMP_START)
    d_patch <- fread(file.patch)
    d_patch <- d_patch[TIMESTAMP_START <= TIMESTAMP_START0, ]

    if (nrow(d) != nrow(d_patch)) {
        warning(sprintf("[w] %s length not match", site_code))
        listk(d, d_patch)
    } else {
        variable.names = colnames(d_patch)
        for (varname in variable.names) {
            d[[varname]] <- d_patch[[varname]]
        }
        fwrite(d, outfile)
    }
} %>% rm_empty()

# those sites have long time in patch
sites_longer = c("AU-TTE", "AU-Wom", "CZ-BK1", "CZ-BK2",
                 "FR-Gri", "NL-Loo", "US-Prr", "ZA-Kru")
# 统计某文件夹下文件的个数
# ls -l |grep "^-"|wc -l
