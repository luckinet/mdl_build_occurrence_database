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
# doi/url     : https://doi.org/10.1594/PANGAEA.869660, https://doi.org/10.1594/PANGAEA.869661, https://doi.org/10.1594/PANGAEA.869662
# license     : _INSERT
# geography   : Global
# period      : 2011
# variables   :
# - cover     : various
# - use       : various
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 526
# ----

thisDataset <- "see2016"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "Global land cover is an essential climate variable and a key biophysical driver for earth system models. While remote sensing technology, particularly satellites, have played a key role in providing land cover datasets, large discrepancies have been noted among the available products. Global land use is typically more difficult to map and in many cases cannot be remotely sensed. In-situ or ground-based data and high resolution imagery are thus an important requirement for producing accurate land cover and land use datasets and this is precisely what is lacking. Here we describe the global land cover and land use reference data derived from the Geo-Wiki crowdsourcing platform via four campaigns.",
              homepage = "https://doi.org/10.1594/PANGAEA.869660, https://doi.org/10.1594/PANGAEA.869661, https://doi.org/10.1594/PANGAEA.869662",
              version = "2021.09",
              licence_link = "https://creativecommons.org/licenses/by/3.0/",
              reference = read.bib(paste0(thisDir, "10.1038_sdata.2017.75-citation.bib")))

new_source(name = thisDataset, date = ymd("2021-09-13"), ontology = path_onto_occurr)


message(" --> handling data")
files <- list.files(path = dir_input, pattern = "tab", full.names = TRUE)

data1 <- read_tsv(files[1], skip = 17)
data2 <- read_tsv(files[2], skip = 24)
data3 <- read_tsv(files[3], skip = 28)


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
# matches <- tibble(new = c(as.character(unique(data$`LCC (LC1 - This is the choice for ...)`))),
#                   old = c("Herbaceous associations", 'Forests',
#                           "Shrubland", "Heterogeneous semi-natural areas",
#                           "AGRICULTURAL AREAS", "Inland waters",
#                           "Open spaces with little or no vegetation"))
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

