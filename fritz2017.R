# ----
# title       : build occurrence database - fritz2017
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-04-17
# version     : 0.0.0
# status      : find data, update, inventarize, validate, normalize, done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://doi.org/10.1038/sdata.2017.75
# license     : _INSERT
# geography   : Global
# period      : 2011
# variables   :
#  - cover    : various
#  - use      : -
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 151943
# ----

thisDataset <- "fritz2017"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "Global land cover is an essential climate variable and a key biophysical driver for earth system models. While remote sensing technology, particularly satellites, have played a key role in providing land cover datasets, large discrepancies have been noted among the available products. Global land use is typically more difficult to map and in many cases cannot be remotely sensed. In-situ or ground-based data and high resolution imagery are thus an important requirement for producing accurate land cover and land use datasets and this is precisely what is lacking. Here we describe the global land cover and land use reference data derived from the Geo-Wiki crowdsourcing platform via four campaigns.",
              homepage = "https://doi.org/10.1594/PANGAEA.869680",
              version = "2021.09",
              licence_link =  "https://creativecommons.org/licenses/by/3.0/",
              reference = read.bib(paste0(thisDir, "10.1038_sdata.2017.75-citation.bib")))

new_source(name = thisDataset, date = ymd("2021-09-13"), ontology = path_onto_occurr)


message(" --> handling data")
data_path <- paste0(thisDir, "GlobalCrowd.tab")
data <- read_tsv(file = data_path, skip = 33)


message("   --> normalizing data")
data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  rename(conf_human_impact = `Conf (Confidence Human Impact, 0 = ...)`,
         conf_landcover = `Conf (Confidence Land Cover, 0 = su...)`,
         abandoned = `Perc [%] (Confidence of abandonment, , ...)`,
         conf_abandoned = Conf, highres = `Resolution (High resolution used)`,
         morethan3 = `Code (More than 3 Land Cover Classe...)`,
         record_dateTime = `Date/Time (The date and time the entry w...)`,
         fieldsize = `Size (Size of agricultural fields, ...)`)

data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data |>
  select(obsID, _INSERT)

schema_fritz2017 <-
  setFormat(header = _INSERT, decimal = _INSERT, thousand = _INSERT,
            na_values = _INSERT) |>
  setFormat(header = 1L) |>
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "externalID", columns = c(4, 3), merge = "-") |>
  setIDVar(name = "disclosed", type = "l", value = TRUE) |>
  setIDVar(name = "date", columns = 21) |>
  setIDVar(name = "irrigated", type = "l", value = FALSE) |>
  setIDVar(name = "present", type = "l", value = TRUE) |>
  setIDVar(name = "sample_type", value = "visual interpretation") |>
  setIDVar(name = "collector", value = "citizen scientist") |>
  setIDVar(name = "purpose", value = "map development") |>
  setIDVar(name = "repetition", columns = c(8, 11, 14), rows = 1, split = "\\(([^,]*),") |>
  setObsVar(name = "cover_perc", columns = c(9, 12, 15), top = 1) |>
  setObsVar(name = "human_impact", columns = c(7, 10, 13), top = 1) |>
  setObsVar(name = "concept", type = "c", columns = c(8, 11, 14), top = 1)

temp <- reorganise(schema = schema_fritz2017, input = data) |>
  filter(!is.na(concept))


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
