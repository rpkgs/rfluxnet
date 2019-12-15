Output_variables_FLUXNET2015_FULLSET = data.table::fread("data-raw/Output_variables_FLUXNET2015_FULLSET.csv")
usethis::use_data(Output_variables_FLUXNET2015_FULLSET, overwrite = TRUE)
