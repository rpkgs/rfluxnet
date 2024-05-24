library(rgee2)
library(rfluxnet)
ee_init(drive=TRUE)
# rgee::ee_Initialize(drive = TRUE)

## ee_extract需重写, 以适应5000bands
# Define bands
bands = c(
  Pa = "surface_pressure", # Pa
  prcp = "total_precipitation_sum", # m
  Tdew = "dewpoint_temperature_2m",
  Tmin = "temperature_2m_min", 
  Tmax = "temperature_2m_max", 
  Tavg = "temperature_2m", 
  Tsoil = "soil_temperature_level_1",
  Rns = "surface_net_solar_radiation_sum",  # J m-2 
  Rnl = "surface_net_thermal_radiation_sum", 
  Rs = "surface_solar_radiation_downwards_sum", 
  Rln = "surface_thermal_radiation_downwards_sum", 
  uwind = "u_component_of_wind_10m",
  vwind = "v_component_of_wind_10m"
  # PET = "potential_evaporation_sum", # m
  # ET = "total_evaporation_sum", 
  # Ec = "evaporation_from_vegetation_transpiration_sum", 
  # Es = "evaporation_from_bare_soil_sum", 
  # Ei = "evaporation_from_the_top_of_canopy_sum"
)

sp = sf2::df2sf(st_flux261) |> _[, 1]

foreach(year = 2001:2023, i = icount()) %do% {
  filter = ee$filter$Filter$calendarRange(year, year, "year")
  col = ee$ImageCollection("ECMWF/ERA5_LAND/DAILY_AGGR")$
    filter(filter)$
    select(bands, names(bands))

  ee_extract2(col, sp, via = "drive", lazy = TRUE,
    outfile = glue("st261_ERA5L_day_{year}.csv")
  )
}
# year = 2010
