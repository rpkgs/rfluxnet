read_dir <- function(indir = "H:/snapflow_0.1.5/csv/sapwood", pattern = "site_md") {
  files <- dir(indir, pattern, full.names = TRUE)

  names <- basename(files) %>% gsub(glue("_{pattern}.csv"), "", .)
  plyr::llply(files %>% set_names(names), fread, .progress = "text")
}

unify_cols <- function(lst) {
  varnames <- sapply(lst, colnames) %>%
    unlist() %>%
    table() %>%
    names()
  lst2 <- purrr::map(lst, function(d) {
    varnames_miss <- setdiff(varnames, colnames(d))
    for (varname in varnames_miss) {
      d[[varname]] <- NA
    }
    d[, .SD, .SDcols = varnames]
  })
  do.call(rbind, lst2) %>% reorder_name("si_code")
  # melt_list(lst2, "site")
}

# env_data
# env_flags
# env_md
# sapf_data
# sapf_flags
# plant_md
# species_md
# site_md
# stand_md
