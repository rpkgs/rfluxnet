library(usethis)
## code to prepare `DATASET` dataset goes here
site_metadata = data.table::fread("data-raw/Site_metadata.csv")
usethis::use_data(site_metadata, overwrite = TRUE)

# sinew::makeOxygen(site_metadata, add_fields = "source")


info = merge(st_flux212[, .(site)], 
  rename(site_metadata, site = SiteCode))

site_metadata[, .(TowerHeight, CanopyHeight, MeasurementHeight)]

write_list2xlsx(info, "site_metadata_flux212.xlsx")

st_plumber170 = fread("data-raw/PLUMBER2_metadata.csv") |> 
  rename(lat = latitude, lon = longitude, 
    z_obs = reference_height, 
    z_canopy = canopy_height) 
use_data(st_plumber170, overwrite = TRUE)
