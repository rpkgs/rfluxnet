# 1. negative values are set to NAN              | vars_noNeg
# 2. negative and zero values are set to NAN     | vars_0na
# 3. QC > 2 set to NAN.
tidy_hourly <- function(dt) {
  # df <- read.csv(file_csv)
  date <- dt[, 1:2]
  # df <- suppressMessages(read.csv(unz(file, file_csv)))
  Id_na <- which(is.na(match(vars_all, colnames(dt))))
  # df[, vars_all[Id_na]] <- NA #this step must be data.frame variables
  if (length(Id_na) > 0) dt[, (vars_all[Id_na]) := NA]

  x_val <- dt[, vars_val, with = F]

  # qc could be -9999 sometimes
  x_qc <- dt[, vars_QC, with = F]
  x_val[x_qc > 2] <- NA

  # manipulate NA values
  for (i in seq_along(vars_val)) {
    var <- vars_val[i]

    I_0 <- numeric() # error fix, 17 Dec' 2017
    if (var %in% var_no_negative) {
      # variables x < 0 set to be 0
      I_0 <- which(x_val[[i]] < 0)
    }
    # if (var %in% vars_0na) {
    #     # variables x <= 0 set to be 0
    #     I_0 <- which(x_val[[i]] < 0)
    # } else if (var %in% vars_noNeg) {
    #     # variables x < 0 set to be 0
    #     I_0 <- which(x_val[[i]] < 0)
    # }
    # else variables (TA_F, TS_F, NEE) x < -9000 set to be NA
    I_na <- which(x_val[[i]] <= -9000 | x_qc[[i]] > 2) # should be caution the short form

    if (length(I_0) > 0) set(x_val, i = I_0, j = i, value = NA) # 09 Mar, 2018
    if (length(I_na) > 0) set(x_val, i = I_na, j = i, value = NA)
  }
  x <- cbind(date, x_val) # add tiemstamp variables, fixed error here
}



tidy_hourly_fullset <- function(d) {
  d[d == -9999] = NA_real_

  d_carbon = select(d, ends_with("VUT_REF")) * 86400 * 12 / 1e6 # umolC/m2/s to gC/m2/d
  vals_noqc = c("TIMESTAMP_START", "SW_IN_POT", "PA", "P", "WS", "RH",
    "NETRAD", "PPFD_IN",
    "NIGHT", "LE_CORR", "H_CORR")

  vars_may <- c("PPFD_IN", "RH", "VPD", "NETRAD", "WD", "G_F_MDS", "G_F_MDS_QC")
  for (var in vars_may) {
    if (!var %in% names(d)) d[[var]] = NA
  }
  d0 = select(d, all_of(vals_noqc)) |>
    rename(date = TIMESTAMP_START, Pa = PA,
      Rs_toa = SW_IN_POT, Rn = NETRAD)

  d_met = select(d,
    -TIMESTAMP_END,
    -all_of(vals_noqc),
    -WD,
    -matches("_JSB"),
    -EBC_CF_N, -EBC_CF_METHOD,
    -starts_with("LE_"), LE_F_MDS, LE_F_MDS_QC, #LE_CORR,
    -starts_with("H_"), H_F_MDS, H_F_MDS_QC, #H_CORR,
    -starts_with(c("RECO", "GPP", "NEE")),
    -ends_with(c("_ERA")), -USTAR)

  d_met[d_met == -9999] = NA_real_

  d_val = d_met |> select(-ends_with("QC")) #|> mutate_all(~ .x %in% c(0, 1)
  d_qc = d_met |> select(ends_with("QC")) #|> mutate_all(~ .x %in% c(0, 1)
  ## check names
  .vars_qc = names(d_qc)
  .vars = gsub("_QC", "", .vars_qc)
  # print2(.vars_qc, .vars)

  d_val = d_val[, ...vars]
  d_qc = d_qc[, ...vars_qc]
  ## 变量有重复的部分，有不重复的部分

  # 0 = measured; 1 = good quality gapfill; 2 = medium; 3 = poor
  d_val[d_qc > 2] = NA_real_

  r = cbind(d0, d_val, d_carbon) |>
    rename_with(~ gsub("_VUT_REF", "", .)) |>
    rename_with(~ gsub("TA", "Tair", .)) |>
    rename_with(~ gsub("WS", "wind", .)) |>
    rename_with(~ gsub("SW_IN", "Rs", .)) |>
    rename_with(~ gsub("LW_IN", "Rln", .))

  r = r |> select(
      -Rs_F_MDS, -Rln_F_MDS, -Tair_F_MDS, -P, -wind,
      -Pa, -VPD_F_MDS
  ) |> rename(
    Rs = Rs_F, Rln = Rln_F, Tair = Tair_F, prcp = P_F, wind = wind_F,
    Pa = PA_F, VPD = VPD_F
  ) |> relocate(date, NIGHT, Rn, Rs_toa, Rs, Rln, PPFD_IN,
    Tair, prcp, RH, VPD, wind, Pa,
    G_F_MDS, starts_with("TS_"),
    starts_with("SWC_"),
    LE = LE_F_MDS, LE_CORR,
    H = H_F_MDS, H_CORR,
    starts_with("Rs"), starts_with("Rln"),
  )

  ans_prcp = r[, lapply(.SD, sum, na.rm = TRUE), .SDcols = "prcp", .(date = floor(date/1e2))]
  ans = r[, lapply(.SD, mean, na.rm = TRUE), .(date = floor(date/1e2))]
  cbind(ans_prcp, select(ans, -date, -prcp)) |>
    mutate(date = as.POSIXct(as.character(date), format = "%Y%m%d%H"))
}
