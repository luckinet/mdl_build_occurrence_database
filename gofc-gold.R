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

thisDataset <- "gofc-gold"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "Towards Better Use of Global Land Cover Datasets and Improved Accuracy Assessment Practices",
              homepage = "https://gofcgold.org/",
              version = _INSERT,
              licence_link = _INSERT,
              reference = read.bib(paste0(thisDir, "_INSERT.bib")))

new_source(name = thisDataset, date = ymd("2021-11-12"), ontology = path_onto_occurr)


message(" --> handling data")
# data1 <- read_excel(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "glc2k_agl11_rndsel.xlsx"), sheet = 1)
# data2 <- read_csv(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "GLCNMO_2008.csv"))
# data3 <- read_csv(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "Globcover2005_April2013_no_commo.csv"))
# data4 <- read_csv(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "step_september152014_70rndsel_igbpcl.csv"))


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
