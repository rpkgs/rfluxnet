## code to prepare `DATASET` dataset goes here
site_metadata = data.table::fread("data-raw/Site_metadata.csv")
usethis::use_data(site_metadata, overwrite = TRUE)

# sinew::makeOxygen(site_metadata, add_fields = "source")
