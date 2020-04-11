st_flux166 <- data.table::fread("data-raw/st_flux166.csv")
usethis::use_data(st_flux166, overwrite = TRUE)

st_flux212 <- data.table::fread("data-raw/st_flux212.csv")
usethis::use_data(st_flux212)
