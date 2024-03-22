Output_variables_OzFlux = data.table::fread("data-raw/Output_variables_OzFlux.csv")
usethis::use_data(Output_variables_OzFlux, overwrite = TRUE)
