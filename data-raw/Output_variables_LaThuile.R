Output_variables_LaThuile = data.table::fread("data-raw/Output_variables_LaThuile.csv")
usethis::use_data(Output_variables_LaThuile, overwrite = TRUE)
