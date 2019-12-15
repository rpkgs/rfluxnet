\dontrun{
library(ncdf4)
library(magrittr)

file   = "OUTPUTS/Nc_files/Flux/AU-Whr_2012-2014_FLUXNET2015_Flux.nc"
ncfile = nc_open(file)

vars_ndim <- map_int(ncfile$var, ~length(.x$varsize))
vars <- vars_ndim %>% {names(.)[. == 3]} %>% print()

plot_nc(ncfile, analysis_type = c("diurnal"), vars, outfile = "diurnal_")
# SumatraPDF("diurnal_DiurnalCycle.pdf")
}
