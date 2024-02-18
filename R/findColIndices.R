#' Finds variables present in input file
#' @return list of variables and their attributes
findColIndices <- function(fileinname, var_names, var_classes,
                           essential_vars,
                           preferred_vars,
                           time_vars, dset_vars, site_log, datasetname, ...) {
  # CSV files in Fluxnet2015 Nov '16 release do not follow a set template
  # and not all files include all variables
  # This function finds which desired variables are present in file
  # and creates a column name and class vector for reading in data

  # Read headers (variable names) of CSV/NetCDF file
  if (datasetname == "OzFlux") { # NetCDF file
    nc <- nc_open(fileinname)
    headers <- c(names(nc$var), names(nc$dim)) # Get variable names
    nc_close(nc)
  } else {
    headers <- read.csv(fileinname, header = FALSE, nrows = 1) # CSV file
  }

  # Find file header indices corresponding to desired variables
  # (returns an empty integer if cannot find variable)
  ind <- sapply(var_names, function(x) which(headers == x))

  # List variables that could not be found in file (instances where ind length equals 0)
  # and remove failed variables from var_name and var_classes vectors
  failed_ind <- which(sapply(ind, length) == 0)
  failed_vars <- var_names[failed_ind] # List failed variables

  # ! failed: "SW_OUT" "SW_OUT_QC" "NETRAD_QC" "USTAR_QC"
  # If found variables not present in file
  if (length(failed_ind) > 0) {
    # Check if any essential meteorological variables missing, abort if so
    if (any(!is.na(essential_vars[failed_ind]))) {
      # Add an exception for VPD and relative humidity
      # Some sites have one or the other available, can use either to derive Qair
      essential_failed <- var_names[failed_ind[which(!is.na(essential_vars[failed_ind]))]]
      stop <- TRUE

      # If RH only missing variable: Check if VPD available, if so don't worry about missing RH
      if (any(failed_vars %in% dset_vars$relhumidity) & length(essential_failed) == 1) {
        # If found VPD, don't stop
        if (any(as.matrix(headers) %in% dset_vars$vpd)) stop <- FALSE
      }

      # If VPD only missing variable: Check if RH available, if so don't worry about missing VPD
      if (any(failed_vars %in% dset_vars$vpd) & length(essential_failed) == 1) {
        # If found RH, don't stop
        if (any(as.matrix(headers) %in% dset_vars$relhumidity)) stop <- FALSE
      }
      if (stop) {
        error <- paste("Cannot find all essential variables in input file (missing: ",
          paste(essential_failed, collapse = ","), "), aborting",
          sep = ""
        )
        stop_and_log(error, site_log)
      }
    }

    # Check if no desired evaluation variables present, abort if so
    if (all(preferred_vars[failed_ind] == TRUE)) {
      error <- paste("Cannot find any evaluation variables in input file (missing: ",
        paste(var_names[failed_ind[which(!is.na(essential_vars[failed_ind]))]], collapse = ","),
        "), aborting",
        sep = ""
      )
      stop_and_log(error, site_log)
    }
    # Remove variables that are not present from variable list
    var_names <- var_names[-failed_ind]
    var_classes <- var_classes[-failed_ind]
  }

  # Find time information
  # Returns time variables and column classes
  time_info <- findTimeInfo(time_vars, headers, site_log, datasetname)

  # Check that column indices for time and other variables don't overlap
  if (length(intersect(time_info$ind, ind)) > 0) {
    error <- paste(
      "Error determining column indices for time and other",
      "variables, two or more variables overlap [ function:",
      match.call()[[1]], "]"
    )
    stop_and_log(error, site_log)
  }
  # Combine column classes for time and other variables
  # If colClass is set to NULL, R won't read column unnecessarily
  columnClasses <- time_info$classes
  columnClasses[unlist(ind)] <- var_classes

  # Combine names of time and other variables and reorder to match CSV file
  # (used later to check that file was read correctly)
  all_vars <- c(var_names, time_info$names)
  all_vars <- all_vars[order(c(unlist(ind), time_info$ind), all_vars)]
  # Reorder variable names so matches the order in CSV file
  var_names <- var_names[order(unlist(ind), var_names)]
  # List outputs
  tcols <- list(
    names = var_names, time_names = time_info$names,
    all_names = all_vars, classes = columnClasses,
    failed_vars = failed_vars
  )
  return(tcols)
}

# #Add an exception for VPD and relative humidity
# #Some sites have one or the other available
# #Missing RH
# if (any(failed_vars %in% dset_vars$relhumidity)) {
#
#   #Check if VPD available, if so don't worry about missing RH
#   if (any(as.matrix(headers) %in% dset_vars$vpd)) {
#
#     #Remove RH from failed vars list
#     ind <- which(failed_vars %in% dset_vars$relhumidity)
#
#     failed_ind <- failed_ind[-ind]
#     failed_vars <- failed_vars[-ind]
#
#   }
#
# }
# #Missing VPD
# if (any(failed_vars %in% dset_vars$vpd)) {
#   #Check if relative humidity available
#
#   #Check if RH available, if so don't worry about missing VPD
#   if (any(as.matrix(headers) %in% dset_vars$relhumidity)) {
#
#     #Remove VPD from failed vars list
#     ind <- which(failed_vars %in% dset_vars$vpd)
#
#     failed_ind  <- failed_ind[-ind]
#     failed_vars <- failed_vars[-ind]
#
#   }
#
# }
#
