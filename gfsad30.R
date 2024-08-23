# ----
# title       : build occurrence database - _INESRT
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-MM-DD
# version     : 0.0.0
# status      : find data, update, inventarize, validate, normalize, done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : _INSERT
# license     : _INSERT
# geography   : _INSERT
# period      : _INSERT
# variables   :
# - cover     : _INSERT
# - use       : _INSERT
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : _INSERT
# features    : _INSERT
# ----

thisDataset <- "gfsad30"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "The GFSAD30 is a NASA funded project to provide high resolution global cropland data and their water use that contributes towards global food security in the twenty-first century. The GFSAD30 products are derived through multi-sensor remote sensing data (e.g., Landsat, MODIS, AVHRR), secondary data, and field-plot data and aims at documenting cropland dynamics from 2000 to 2025.",
              homepage = "https://croplands.org/app/data/search?page=1&page_size=200",
              version = "2021.09",
              licence_link = _INSERT,
              reference = read.bib(paste0(thisDir, "GFSAD30.bib")))

new_source(name = thisDataset, date = ymd("2021-09-14"), ontology = path_onto_occurr)


message(" --> handling data")
# data <- read_csv(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "GFSAD30_2000-2010.csv"), col_types = "iiiddciiiiicccl") %>%
#   bind_rows(read_csv(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "GFSAD30_2011-2021.csv"), col_types = "iiiddciiiiicccl"))
# data <- data %>%
#   filter(!land_use_type == 0 | !crop_primary == 0) %>%
#   mutate(jointCol = paste(land_use_type, crop_primary, sep = "-"))


message("   --> normalizing data")
# mutate(month = gsub(0, "01", month)) %>%
#   date = ymd(paste(year, month, "01", sep = "-")),
# externalValue = paste(land_use_type, crop_primary, sep = "-"),
# irrigated = case_when(water == 0 ~ NA,
#                       water == 1 ~ F,
#                       water == 2 ~ T)
data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("lon", "lat"), crs = _INSERT) #|>
# st_transform(crs = 4326)

geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data |>
  select(obsID, _INSERT)

schema_INSERT <-
  setFormat(header = _INSERT, decimal = _INSERT, thousand = _INSERT,
            na_values = _INSERT) |>
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "externalID", columns = _INSERT) |>
  setIDVar(name = "disclosed", type = "l", value = _INSERT) |>
  setIDVar(name = "date", columns = _INSERT) |>
  setIDVar(name = "irrigated", type = "l", value = _INSERT) |>
  setIDVar(name = "present", type = "l", value = TRUE) |>
  setIDVar(name = "sample_type", value = "field") %>%
  setIDVar(name = "collector", value = "expert") %>%
  setIDVar(name = "purpose", value = "map development") %>%
  setObsVar(name = "concept", type = "c", columns = _INSERT)

temp <- reorganise(schema = schema_INSERT, input = data)


message("   --> harmonizing with ontology")
out <- matchOntology(table = temp,
                     columns = "concept",
                     colsAsClass = FALSE,
                     dataseries = thisDataset,
                     ontology = path_onto_occurr)
# newConcepts <- tibble(target = c("Temporary cropland", "Open spaces with little or no vegetation", "Herbaceous associations",
#                                  "Forests", "WATER BODIES", "Shrubland",
#                                  "Permanent cropland", "rice", "Urban fabric",
#                                  "Temporary cropland", "sugarcane", "Fallow",
#                                  "potato", "rice", "wheat",
#                                  "maize", "barley", "alfalfa",
#                                  "cotton", "oil palm", "soybean",
#                                  "cassava", "peanut", "millet",
#                                  "sunflower", "LEGUMINOUS CROPS", "Temporary cropland",
#                                  "Temporary grazing", "rapeseed"),
#                       new = unique(temp$jointCol),
#                       class = c("landcover", "landcover", "landcover",
#                                 "landcover", "landcover group", "landcover",
#                                 "landcover", "commodity", "landcover",
#                                 "landcover", "commodity", "land-use",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "group", "landcover",
#                                 "land-use", "commodity"),
#                       description = NA,
#                       match = "close",
#                       certainty = 3)

out <- out |>
  # summarise(.by = c(datasetID, obsID, externalID, disclosed, date, irrigated, present, sample_type, collector, purpose, external, match),
  #           concept = paste0(na.omit(concept), collapse = " | "),
  #           id = paste0(na.omit(id), collapse = " | ")) |>
  left_join(geom, by = "obsID")


message(" --> writing output")
st_write(obj = out, dsn = paste0(thisDir, "output.gpkg"))
saveRDS(object = other, file = paste0(thisDir, "output_other.rds"))

beep(sound = 10)
message("\n     ... done")
