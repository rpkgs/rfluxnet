# - `Radiation`: `W m-2` 
# - `PPFD_IN`, `CO2_F_MDS`: `µmolPhoton m-2 s-1`
# - `Temperature`: `°C`
# - `SWC_F_MDS`: `%`
# - `Carbon`: has been convert `umolC/m2/s` to `gC/m2/d`
# - `VPD`: kPa

st1 = st_plumber170[IGBP_veg_short == "CRO"]
st2 = st_flux212[IGBP == "CRO"]

sites1 = st1$site
sites2 = st2$site

sites = unique_sort(c(sites1, sites2))
setdiff(sites, sites2) # "DK-Ris" "ES-ES2" "IE-Ca1" "US-Bo1"

sites_C4 = c("US-Ne1", "US-Ne2", "US-Ne3", "DE-Kli", "FR-Gri")
df = fread("OUTPUT/fluxsites212_FULLSET_D1_v20240322 (80%).csv")

d_crop = df[site %in% sites_C4, ]
fwrite(d_crop, "scripts/C3&C4/FlUXNET2015_CROP-C4_daily_5sp.csv")
# setdiff()
# st_flux212
