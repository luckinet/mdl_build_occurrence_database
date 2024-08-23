# ----
# title       : build occurrence database - _INESRT
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-04-17
# version     : 0.0.0
# status      : find data, update, inventarize, validate, normalize, done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://www.nature.com/articles/s41597-022-01332-3
# license     : _INSERT
# geography   : Global
# period      : 2015
# variables   :
# - cover     : VEGETATED
# - use       : various
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 226323
# ----

thisDataset <- "lesiv2020"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "The data set, in a form of table, contains information on Human Impact on Forests that was collected during a few crowd sourcing campaigns (Human Impact on Tropical Forest, Human Impact on Temperate Forest and Human Impact on Boreal Forest). the data set is not yet final. We expect to publish the final version under Open Access in nearest future.",                                              # the abstract (if paper available) or project description
              homepage = "https://zenodo.org/record/3356758",
              version = "2020.10",
              licence_link = "unknown",
              reference = read.bib(paste0(thisDir, "ref.bib")))

new_source(name = thisDataset, date = ymd("2020-10-21"), ontology = path_onto_occurr)


message(" --> handling data")
data_path <- paste0(dir_input, "final_training_data.csv")

data <- read_csv(file = data_path)


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

schema_lesiv202 <-
  setFormat(header = 1L) %>%
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "externalID", columns = 3) |>
  setIDVar(name = "disclosed", type = "l", value = FALSE) |>
  setIDVar(name = "date", value = "2015-01-01") %>%
  setIDVar(name = "irrigated", type = "l", value = FALSE) |>
  setIDVar(name = "present", type = "l", value = TRUE) |>
  setIDVar(name = "sample_type", value = "visual interpretation") %>%
  setIDVar(name = "collector", value = "citizen scientist") %>%
  setIDVar(name = "purpose", value = "validation") %>%
  setObsVar(name = "concept", type = "c", columns = 7)

temp <- reorganise(schema = schema_lesiv202, input = data)


message("   --> harmonizing with ontology")
# matches <- tibble(new = as.character(unique(data$level12)),
#                   old = c("Palm plantations", "Undisturbed Forest", NA,
#                           "Tree orchards", "Naturally Regenerating Forest",
#                           "Woody plantation", "Tree orchards",
#                           "Undisturbed Forest", "Planted Forest"))
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
