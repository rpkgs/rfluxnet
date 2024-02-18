#' Gets possible varnames for FLUXNET FULLSET/SUBSET and La Thuile
#' @param datasetname one of "FLUXNET2015", "LaThuile" and "OzFlux"
#' @param flx2015_version (optional) only for FLUXNET2015, one of "SUBSET" and "FULLSET"
#' @param add_psurf (optional) only for LaThuile
#'
#' @examples
#' get_varnames("FLUXNET2015")
#' @export
get_varnames <- function(datasetname, flx2015_version = "FULLSET", add_psurf = FALSE) {
  # These are used for unit conversions etc.
  # First instance is FLUXNET2015 FULLSET,
  # Second FLUXNET2015 SUBSET
  # Third La Thuile
  if (datasetname == "FLUXNET2015" & flx2015_version == "SUBSET") {
    ind <- 2
  } else if (datasetname == "LaThuile") {
    ind <- 3
  } else if (datasetname == "OzFlux") {
    ind <- 4
  } else {
    # Else assume FLUXNET2015 fullset format, i.e. if (datasetname=="FLUXNET2015" & flx2015_version=="FULLSET")
    ind <- 1
  }

  # La Thuile PSurf exception
  if (add_psurf) {
    lt_psurf <- "PSurf_synth"
  } else {
    lt_psurf <- NULL
  }

  tair <- list(
    c("TA_F_MDS", "TA_F", "TA_ERA"),
    c("TA_F"),
    c("Ta_f"),
    c("Ta")
  )
  precip <- list(
    c("P", "P_F", "P_ERA"),
    c("P_F"),
    c("Precip_f"),
    c("Precip")
  )
  airpressure <- list(
    c("PA", "PA_ERA", "PA_F"),
    c("PA_F"),
    c(lt_psurf),
    c("ps")
  )
  co2 <- list(
    c("CO2_F_MDS"),
    c("CO2_F_MDS"),
    c("CO2"),
    c("Cc")
  )
  par <- list(
    c("PPFD_IN"),
    c("PPFD_IN"),
    c("PPFD_f"),
    c("NULL")
  ) # check if available?
  relhumidity <- list(
    c("RH"),
    c("RH"),
    c("Rh"),
    c("RH")
  )
  lwdown <- list(
    c("LW_IN_F_MDS", "LW_IN_ERA", "LW_IN_F"),
    c("LW_IN_F"),
    c("LWin"),
    c("Fld")
  )
  swdown <- list(
    c("SW_IN_F_MDS", "SW_IN_ERA", "SW_IN_F"),
    c("SW_IN_F"),
    c("SWin"),
    c("Fsd")
  )
  vpd <- list(
    c("VPD_F_MDS", "VPD_ERA", "VPD_F"),
    c("VPD_F"),
    c("VPD_f"),
    c("VPD")
  )
  wind <- list(
    c("WS", "WS_ERA", "WS_F"),
    c("WS_F"),
    c("WS_f"),
    c("Ws")
  )

  outs <- list(
    tair = tair[[ind]],
    precip = precip[[ind]],
    airpressure = airpressure[[ind]],
    co2 = co2[[ind]],
    par = par[[ind]],
    swdown = swdown[[ind]],
    relhumidity = relhumidity[[ind]],
    lwdown = lwdown[[ind]],
    vpd = vpd[[ind]],
    wind = wind[[ind]]
  )
  return(outs)
}
