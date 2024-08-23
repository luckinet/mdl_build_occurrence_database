# ----
# title       : build occurrence database - _INESRT
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-04-17
# version     : 0.0.0
# status      : validate, normalize, done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://doi.org/10.1038/sdata.2017.70
# license     : _INSERT
# geography   : Eurasia
# period      : 1875 - 2014
# variables   :
# - cover     : VEGETATED
# - use       : _INSERT
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 10351
# ----

thisDataset <- "schepaschenko2017"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "The most comprehensive dataset of in situ destructive sampling measurements of forest biomass in Eurasia have been compiled from a combination of experiments undertaken by the authors and from scientific publications. Biomass is reported as four components: live trees (stem, bark, branches, foliage, roots); understory (above- and below ground); green forest floor (above- and below ground); and coarse woody debris (snags, logs, dead branches of living trees and dead roots), consisting of 10,351 unique records of sample plots and 9,613 sample trees from ca 1,200 experiments for the period 1930–2014 where there is overlap between these two datasets. The dataset also contains other forest stand parameters such as tree species composition, average age, tree height, growing stock volume, etc., when available. Such a dataset can be used for the development of models of biomass structure, biomass extension factors, change detection in biomass structure, investigations into biodiversity and species distribution and the biodiversity-productivity relationship, as well as the assessment of the carbon pool and its dynamics, among many others.",
              homepage = "https://doi.org/10.1594/PANGAEA.871492",
              version = "2021.12",
              licence_link = "https://creativecommons.org/licenses/by/4.0/",
              reference = read.bib(paste0(thisDir, "Schepaschenko-etal_2017.bib")))

new_source(name = thisDataset, date = ymd("2021-12-17"), ontology = path_onto_occurr)


message(" --> handling data")
data_path <- paste0(input_dir, "Biomass_plot_DB.tab")
data <- read_tsv(file = data_path,
                 skip = 54)


message("   --> normalizing data")
data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("Longitude", "Latitude"), crs = _INSERT) #|>
# st_transform(crs = 4326)

geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data |>
  select(obsID, _INSERT)

schema_INSERT <-
  setFormat(header = 1L) %>%
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "externalID", columns = 2) |>
  setIDVar(name = "disclosed", type = "l", value = TRUE) |>
  setIDVar(name = "date", columns = _INSERT) |> #`Date (Year of measurements)`
  setIDVar(name = "irrigated", type = "l", value = FALSE) |>
  setIDVar(name = "present", type = "l", value = TRUE) |>
  setIDVar(name = "sample_type", value = "field") %>%
  setIDVar(name = "collector", value = "expert") %>%
  setIDVar(name = "purpose", value = "study") %>%
  setObsVar(name = "concept", type = "c", columns = _INSERT) #`ID (Unique record ID)`, Origin

temp <- reorganise(schema = schema_schepaschenko2017, input = data)


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
