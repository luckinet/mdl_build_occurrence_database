# ----
# title       : build occurrence database - _INESRT
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-MM-DD
# version     : 0.0.0
# status      : find data, update, inventarize, validate, normalize, done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md")); landcover for ML training
# ----
# doi/url     : https://doi.org/10.1038/s41597-023-02798-5
# license     : _INSERT
# geography   : Global
# period      : 1984 - 2020
# variables   :
# - cover     : various
# - use       : -
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 1874995
# ----

thisDataset <- "stanimirova2023"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "State-of-the-art cloud computing platforms such as Google Earth Engine (GEE) enable regional to-global land cover and land cover change mapping with machine learning algorithms. However, collection of high-quality training data, which is necessary for accurate land cover mapping, remains costly and labor-intensive. To address this need, we created a global database of nearly 2 million training units spanning the period from 1984 to 2020 for seven primary and nine secondary land cover classes. Our training data collection approach leveraged GEE and machine learning algorithms to ensure data quality and biogeographic representation...",
              homepage = "https://doi.org/10.1038/s41597-023-02798-5",
              version = "2024.02",
              licence_link = "https://creativecommons.org/licenses/by/4.0/",
              reference = read.bib(paste0(thisDir, "10.1038_s41597-023-02798-5-citation.bib")))

new_source(name = thisDataset, date = ymd("2024-02-15"), ontology = path_onto_occurr)

message(" --> handling data")
data_path <- paste0(dir_input, "bu_glance_training_dataV1.parquet")
data <- read_parquet(file = data_path)


message("   --> normalizing data")
data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("_INSERT", "_INSERT"), crs = _INSERT) #|>
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
  setIDVar(name = "present", type = "l", value = _INSERT) |>
  setIDVar(name = "sample_type", value = _INSERT) |>
  setIDVar(name = "collector", value = _INSERT) |>
  setIDVar(name = "purpose", value = _INSERT) |>
  setObsVar(name = "concept", type = "c", columns = _INSERT)

temp <- reorganise(schema = schema_INSERT, input = data)


message("   --> harmonizing with ontology")
out <- matchOntology(table = temp,
                     columns = "concept",
                     colsAsClass = FALSE,
                     dataseries = thisDataset,
                     ontology = path_onto_occurr)

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
