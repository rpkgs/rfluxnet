#! /usr/bin/Rscript --no-init-file
# Dongdong Kong ----------------------------------------------------------------
# Copyright (c) 2021 Dongdong Kong. All rights reserved.
source('scripts/main_pkgs.R')

### 1. 清洗metadata -----------------------------------------------------------
## 1.1 sapwood scale
indir <- "H:/snapflow_0.1.5/csv/sapwood"
md_plant   <- read_dir(indir, "plant_md") %>% unify_cols()
md_species <- read_dir(indir, "species_md") %>% unify_cols()
md_site    <- read_dir(indir, "site_md") %>% unify_cols()
md_stand   <- read_dir(indir, "stand_md") %>% unify_cols()
md_env     <- read_dir(indir, "env_md") %>% unify_cols()

write_list2xlsx(listk(md_plant, md_species, md_site, md_stand, md_env),
                glue("sapflow_metadata_sapwood_{nrow(md_site)}sites.xlsx"))

## 1.2 plant scale
indir = "H:/snapflow_0.1.5/csv/plant"
md_plant   <- read_dir(indir, "plant_md") %>% unify_cols()
md_species <- read_dir(indir, "species_md") %>% unify_cols()
md_site    <- read_dir(indir, "site_md") %>% unify_cols()
md_stand   <- read_dir(indir, "stand_md") %>% unify_cols()
md_env     <- read_dir(indir, "env_md") %>% unify_cols()

write_list2xlsx(listk(md_plant, md_species, md_site, md_stand, md_env),
                glue("sapflow_metadata_plant_{nrow(md_site)}sites.xlsx"))

## 1.3 leaf scale
indir = "H:/snapflow_0.1.5/csv/leaf"
md_plant   <- read_dir(indir, "plant_md") %>% unify_cols()
md_species <- read_dir(indir, "species_md") %>% unify_cols()
md_site    <- read_dir(indir, "site_md") %>% unify_cols()
md_stand   <- read_dir(indir, "stand_md") %>% unify_cols()
md_env     <- read_dir(indir, "env_md") %>% unify_cols()
write_list2xlsx(listk(md_plant, md_species, md_site, md_stand, md_env),
                glue("sapflow_metadata_leaf_{nrow(md_site)}sites.xlsx"))

l_sapflow = read_xlsx2list("sapflow_metadata_sapwood_165sites.xlsx")
l_plant   = read_xlsx2list("sapflow_metadata_plant_194sites.xlsx")
l_leaf    = read_xlsx2list("sapflow_metadata_leaf_39sites.xlsx")

# 数据重叠情况
sapflow_metadata = listk(sapflow = l_sapflow, plant = l_plant, leaf = l_leaf) %>%
    purrr::transpose() %>%
    map_depth(2, as.data.table)

use_data(sapflow_metadata, overwrite = TRUE)
# d = sapflow_metadata$md_site %>%
#     map(~.[, .(si_code, si_igbp, si_biome, lon = si_long, lat = si_lat, si_flux_network,
#                si_paper, si_country)])
# info = do.call(rbind, d) %>% unique()
# st_sapflow202 = d = sapflow_metadata$md_site %>%
#     do.call(rbind, .) %>% unique()
st_sapflow202 = read_xlsx("st_sapflow202.xlsx")
use_data(st_sapflow202, overwrite = TRUE)


# match2(l_plant$md_site$si_code, l_snapflow$md_site$si_code)
# match2(l_plant$md_site$si_code, l_snapflow$md_site$si_code)

# 借助MODIS IGBP数据，选择植被类型均一的站点

