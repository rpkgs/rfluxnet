
df = fread("OUTPUT/fluxsites166_FULLSET_daily_v20191216 (60%).csv")
sites = st_flux166[grep("CN", site), site]

d = df[site %in% sites]
d[, .N, .(site, year)] %>% print(n = 40)

site0 = "CN-Dan"
d[site == site0]
