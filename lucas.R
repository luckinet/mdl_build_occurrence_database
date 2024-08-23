# ----
# title       : build occurrence database - lucas
# description : this script integrates data of 'lucas' (https://ec.europa.eu/eurostat/web/lucas)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-07-10
# version     : 1.0.0
# status      : done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://ec.europa.eu/eurostat/web/lucas/database/primary-data, https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/land-cover#umz
# license     : _INSERT
# geography   : Europe
# period      : 2006, 2009, 2012, 2015, 2018, 2022
# variables   :
# - cover     : all
# - use       : all
# sampling    : field
# purpose     : validation
# data type   : point
# features    : 1727210
# ----

thisDataset <- "lucas"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "Mapping pan-European land cover using Landsat spectral-temporal metrics and the European LUCAS survey",
              homepage = "https://ec.europa.eu/eurostat/web/lucas/database/primary-data",
              version = "2024.07",
              licence_link = "unknown",
              reference = read.bib(paste0(thisDir, "S0034425718305546.bib")))

new_source(name = thisDataset, date = ymd("2024-07-08"), ontology = path_onto_odb)



message(" --> handling data")
data_path_cmpr <- paste0(thisDir, "EU_LUCAS_2022.zip")
unzip(exdir = thisDir, zipfile = data_path_cmpr)

data2006 <- list.files(path = thisDir, pattern = "_2006", full.names = TRUE)
if(!any(str_detect(data2006, "EU_2006"))){
  data2006 |>
    map(.f = function(ix){
      read_csv(ix, col_types = "dddccccddddcdddcddcd")
    }) |>
    bind_rows() |>
    write_csv(file = paste0(thisDir, "EU_2006.csv"))
}


message("   --> normalizing data")
# first prepare the subsets ...
# data2006 <- read_csv(paste0(thisDir, "/EU_2006.csv"), col_types = "cddccccddddcdddcddcd") |>
#   rename(SURVEY_DATE = SURV_DATE) |>
#   mutate(OBS_TYPE = if_else(OBS_TYPE  == 1, "field", "visual interpretation"),
#          LC2 = as.character(LC2),
#          LU2 = as.character(LU2),
#          SURVEY_DATE = dmy(SURVEY_DATE)) |>
#   select(-GPS_LONG, -GPS_LAT, -GPS_EW, -GPS_PROJ) |>
#   st_as_sf(coords = c("X_LAEA", "Y_LAEA"), crs = 3035) |>
#   st_transform(crs = 4326)
#
# data2009 <- read_csv(paste0(thisDir, "/EU_2009_20200213.csv")) |>
#   rename(LC1_SP = LC1_SPECIES,
#          LC2_SP = LC2_SPECIES) |>
#   mutate(POINT_ID = as.character(POINT_ID),
#          OBS_TYPE = if_else(OBS_TYPE %in% c(1, 2), "field", "visual interpretation"),
#          TH_LONG = if_else(TH_EW == "W", TH_LONG * -1, TH_LONG),
#          SURVEY_DATE = dmy(SURVEY_DATE)) |>
#   select(-GPS_LONG, -GPS_LAT, -GPS_EW, -GPS_PROJ, -GPS_ALT) |>
#   filter(!is.na(TH_LAT) | !is.na(TH_LONG)) |>
#   st_as_sf(coords = c("TH_LONG", "TH_LAT"), crs = 4326)
#
# data2012 <- read_csv(paste0(thisDir, "/EU_2012_20200213.csv")) |>
#   rename(LC1_SP = LC1_SPECIES,
#          LC2_SP = LC2_SPECIES) |>
#   mutate(LC2_SP = as.character(LC2_SP),
#          OBS_TYPE = if_else(OBS_TYPE %in% c(1, 2), "field", "visual interpretation"),
#          SURVEY_DATE = dmy(SURVEY_DATE)) |>
#   select(-GPS_PROJ, -GPS_LAT, -GPS_LONG, -GPS_EW, -GPS_ALT) |>
#   filter(!is.na(TH_LAT) | !is.na(TH_LONG)) |>
#   st_as_sf(coords = c("TH_LONG", "TH_LAT"), crs = 4326)
#
# data2015 <- read_csv(paste0(thisDir, "/EU_2015_20200225.csv")) |>
#   rename(LC1_SP = LC1_SPECIES,
#          LC2_SP = LC2_SPECIES) |>
#   mutate(LC2_SP = as.character(LC2_SP),
#          OBS_TYPE = if_else(OBS_TYPE %in% c(1, 2), "field", if_else(OBS_TYPE %in% c(3, 7), "visual interpretation", NA_character_)),
#          SURVEY_DATE = dmy(SURVEY_DATE)) |>
#   select(-GPS_PROJ, -GPS_LAT, -GPS_LONG, -GPS_EW, -GPS_ALTITUDE) |>
#   filter(!is.na(TH_LAT) | !is.na(TH_LONG)) |>
#   st_as_sf(coords = c("TH_LONG", "TH_LAT"), crs = 4326)
#
# data2018 <- read_csv(paste0(thisDir, "/EU_2018_20200213.csv")) |>
#   rename(LC1_SP = LC1_SPEC,
#          LC2_SP = LC2_SPEC) |>
#   mutate(LC2_SP = as.character(LC2_SP),
#          OBS_TYPE = if_else(OBS_TYPE %in% c(1, 2), "field", if_else(OBS_TYPE %in% c(3, 7), "visual interpretation", NA_character_)),
#          SURVEY_DATE = dmy(SURVEY_DATE)) |>
#   select(-GPS_PROJ, -GPS_LAT, -GPS_LONG, -GPS_EW, -GPS_ALTITUDE) |>
#   filter(!is.na(TH_LAT) | !is.na(TH_LONG)) |>
#   st_as_sf(coords = c("TH_LONG", "TH_LAT"), crs = 4326)
#
# data2022 <- read_csv(paste0(thisDir, "/EU_LUCAS_2022.csv")) |>
#   rename(LC1 = SURVEY_LC1,
#          LC2 = SURVEY_LC2,
#          LC1_SP = SURVEY_LC1_SPEC,
#          LC2_SP = SURVEY_LC2_SPEC,
#          LU1 = SURVEY_LU1,
#          LU2 = SURVEY_LU2,
#          LU1_TYPE = SURVEY_LU1_TYPE,
#          LU2_TYPE = SURVEY_LU2_TYPE,
#          NUTS0 = POINT_NUTS0,
#          NUTS1 = POINT_NUTS1,
#          NUTS2 = POINT_NUTS2,
#          NUTS3 = POINT_NUTS3) |>
#   mutate(POINT_ID = as.character(POINT_ID),
#          LC2_SP = as.character(LC2_SP),
#          SURVEY_DATE = as.character(SURVEY_DATE),
#          OBS_TYPE = if_else(SURVEY_OBS_TYPE %in% c(1, 2), "field", if_else(SURVEY_OBS_TYPE %in% c(3, 7), "visual interpretation", NA_character_)),
#          SURVEY_DATE = ymd(SURVEY_DATE)) |>
#   select(-`...1`, -SURVEY_GPS_PROJ, -SURVEY_GPS_LAT, -SURVEY_GPS_LONG, -SURVEY_GPS_ALTITUDE) |>
#   st_as_sf(coords = c("POINT_LONG", "POINT_LAT"), crs = 4326)
#
# # ... then bind them and proceed
# data <- data2006 |>
#   bind_rows(data2009) |>
#   bind_rows(data2012) |>
#   bind_rows(data2015) |>
#   bind_rows(data2018) |>
#   bind_rows(data2022) |>
#   # assign all relevant landcover and potentially species information into one column
#   mutate(obsID = row_number(), .before = 1,
#          LC1 = if_else(LC1 %in% c("", "0", "8"), NA_character_,
#                        if_else(!is.na(LC1_SP) & !LC1_SP %in% c("0", "8"), LC1_SP, LC1)),
#          LC2 = if_else(LC2 %in% c("", "0", "8"), NA_character_,
#                        if_else(!is.na(LC2_SP) & !LC2_SP %in% c("0", "8"), LC2_SP, LC2)))

data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("_INSERT", "_INSERT"), crs = _INSERT) #|>
# st_transform(crs = 4326)

geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data |>
  select(obsID, -POINT_ID, -SURVEY_DATE, -OBS_TYPE, -LC1, -LC1_SP, -LC2, -LC2_SP, -LU1, -LU1_TYPE, -LU2, -LU2_TYPE)

schema_lucas <-
  setFormat(header = 1L) |>
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "externalID", columns = 2) |>
  setIDVar(name = "disclosed", type = "l", value = TRUE) |>
  setIDVar(name = "date", columns = 6) |>
  setIDVar(name = "irrigated", type = "l", value = FALSE) |>
  setIDVar(name = "present", type = "l", value = TRUE) |>
  setIDVar(name = "sample_type", columns = 7) |>
  setIDVar(name = "collector", value = "expert") |>
  setIDVar(name = "purpose", value = "validation") |>
  setIDVar(name = "sample_nr", columns = c(11, 12), rows = 1) |>
  setObsVar(name = "concept", type = "c", columns = c(11, 12), top = 1)


message("   --> harmonizing with ontology")
out <- matchOntology(table = temp,
                     columns = "concept",
                     colsAsClass = FALSE,
                     dataseries = thisDataset,
                     ontology = path_onto_occurr)

out <- out |>
  filter(!is.na(id) & !is.na(concept)) |>
  pivot_wider(id_cols = c(datasetID, obsID, externalID, disclosed, date, irrigated, present, sample_type, collector, purpose), names_from = sample_nr,
              values_from = concept, values_fn = ~paste0(na.omit(.x), collapse = " | ")) |>
  unite(col = "ontoName", LC1, LC2, sep = " | ", na.rm = TRUE)


message(" --> writing output")
st_write(obj = out, dsn = paste0(thisDir, "output.gpkg"))
saveRDS(object = other, file = paste0(thisDir, "output_other.rds"))

beep(sound = 10)
message("\n     ... done")
