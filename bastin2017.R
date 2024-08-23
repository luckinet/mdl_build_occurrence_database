# ----
# title       : build occurrence database - bastin2017
# description : this script integrates data of 'bastin2017' (https://doi.org/10.1126/science.aam6527)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Steffen Ehrmann
# date        : 2024-04-05
# version     : 1.0.0
# status      : done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://doi.org/10.1126/science.aam6527
# license     : unknown
# geography   : Global
# period      : 2015
# variables   :
# - cover     : VEGETATED; forest dryland
# - use       : -
# sampling    : visual interpretation
# purpose     : study
# data type   : point
# features    : 213796
# ----

thisDataset <- "bastin2017"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "The extent of forest in dryland biomes",
              homepage = "https://doi.org/10.1126/science.aam6527",
              version = "2021-12-15",
              licence_link = "unknown",
              reference = read.bib(paste0(thisDir, "csp_356_.bib")))

new_source(name = thisDataset, date = ymd("2021-12-15"), ontology = path_onto_occurr)


message(" --> handling data")
data_path_cmpr <- paste0(thisDir, "aam6527_Bastin_Database-S1.csv.zip")
data_path <- paste0(thisDir, "aam6527_Bastin_Database-S1.csv")

unzip(exdir = thisDir, zipfile = data_path_cmpr)

data <- read_delim(file = data_path, delim = ";")


message("   --> normalizing data")
data <- data |>
  filter(!is.na(location_x) & !is.na(location_y)) |>
  mutate(present = if_else(land_use_category == "forest", TRUE, FALSE)) |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("location_x", "location_y"), crs = 4326)


geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data |>
  select(obsID, region = dryland_assessment_region, aridity = Aridity_zone, cover.tree = tree_cover)

schema_bastin2017 <-
  setFormat(header = 1L, decimal = ".") |>
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  # setIDVar(name = "externalID", columns = _INSERT) |>
  setIDVar(name = "disclosed", type = "l", value = TRUE) |>
  setIDVar(name = "date", value = "2015") |>
  setIDVar(name = "irrigated", type = "l", value = FALSE) |>
  setIDVar(name = "present", type = "l", columns = 6) |>
  setIDVar(name = "sample_type", value = "visual interpretation") |>
  setIDVar(name = "collector", value = "citizen scientist") |>
  setIDVar(name = "purpose", value = "study") |>
  setObsVar(name = "concept", type = "c", columns = 4)

temp <- reorganise(schema = schema_bastin2017, input = data)


message("   --> harmonizing with ontology")
out <- matchOntology(table = temp,
                     columns = "concept",
                     colsAsClass = FALSE,
                     dataseries = thisDataset,
                     ontology = path_onto_occurr)

out <- out |>
  summarise(.by = c(datasetID, obsID, disclosed, date, irrigated, present, sample_type, collector, purpose, external, match),
            concept = paste0(na.omit(concept), collapse = " | "),
            id = paste0(na.omit(id), collapse = " | ")) |>
  left_join(geom, by = "obsID")


message(" --> writing output")
st_write(obj = out, dsn = paste0(thisDir, "output.gpkg"))
saveRDS(object = other, file = paste0(thisDir, "output_other.rds"))

beep(sound = 10)
message("\n     ... done")

