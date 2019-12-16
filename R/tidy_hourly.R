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
