# 1.1 https://developers.google.com/earth-engine/datasets/catalog/MODIS_006_MCD12Q1
IGBPnames_006 <- c(
  "ENF", "EBF", "DNF", "DBF", "MF", # 5 types
  "CSH", "OSH", "WSA", "SAV", "GRA", "WET",
  "CRO", "URB", "CNV", "SNOW", "BSV", "water"
) # 1:17
IGBPcodes_006 <- setNames(1:17, IGBPnames_006)

# 1.2 https://developers.google.com/earth-engine/datasets/catalog/MODIS_051_MCD12Q1
IGBPnames_005 <- c(
  "water", # 0
  "ENF", "EBF", "DNF", "DBF", "MF",
  "CSH", "OSH", "WSA", "SAV", "GRA", "WET",
  "CRO", "URB", "CNV", "SNOW", "BSV", "NA"
) # 0:16, 254
IGBPcodes_005 <- setNames(c(0:16, 254), IGBPnames_005)

#' @export
IGBP_006 <- data.table(name = IGBPnames_006, code = IGBPcodes_006)

#' @export
IGBP_005 <- data.table(name = IGBPnames_005, code = IGBPcodes_005)
