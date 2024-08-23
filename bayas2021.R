# ----
# title       : build occurrence database - bayas2021
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-MM-DD
# version     : 0.0.0
# status      : find data, update, inventarize, validate, normalize, done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://doi.org/10.22022/NODES/06-2021.122
# license     : _INSERT
# geography   : Tropical
# period      : _INSERT
# variables   :
#  - cover    : VEGETATED
#  - use      : -
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 1158022
# ----

thisDataset <- "bayas2021"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "The data set is the result of the Drivers of Tropical Forest Loss crowdsourcing campaign. The campaign took place in December 2020. A total of 58 participants contributed validations of almost 120k locations worldwide. The locations were selected randomly from the Global Forest Watch tree loss layer (Hansen et al 2013), version 1.7. At each location the participants were asked to look at satellite imagery time series using a customized Geo-Wiki user interface and identify drivers of tropical forest loss during the years 2008 to 2019 following 3 steps: Step 1) Select the predominant driver of forest loss visible on a 1 km square (delimited by a blue bounding box); Step 2) Select any additional driver(s) of forest loss and; Step 3) Select if any roads, trails or buildings were visible in the 1 km bounding box. The Geo-Wiki campaign aims, rules and prizes offered to the participants in return for their work can be seen here: https://application.geo-wiki.org/Application/modules/drivers_forest_change/drivers_forest_change.html . The record contains 3 files: One “.csv” file with all the data collected by the participants during the crowdsourcing campaign (1158021 records); a second “.csv” file with the controls prepared by the experts at IIASA, used for scoring the participants (2001 unique locations, 6157 records) and a ”.docx” file describing all variables included in the two other files. A data descriptor paper explaining the mechanics of the campaign and describing in detail how the data was generated will be made available soon.",
              homepage = "https://doi.org/10.22022/NODES/06-2021.122",
              version = "2022.04",
              licence_link = "https://creativecommons.org/licenses/by-sa/4.0/",
              reference = read.bib(paste0(thisDir, "Crowdsourcing.bib")))

new_source(name = thisDataset, date = ymd("2022-04-14"), ontology = path_onto_occurr)


message(" --> handling data")
data_path_cmpr <- paste0(thisDir, "ILUC_DARE_x_y.zip")
unzip(exdir = thisDir, zipfile = data_path_cmpr)

data_path <- paste0(thisDir, "ILUC_DARE_campaign_x_y.csv")
data <- read_csv(file = data_path)


message(" --> normalizing data")
data <- data |>
  mutate(obsID = row_number(), .before = 1) |>
  st_as_sf(coords = c("x", "y"), crs = 4326)

geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data |>
  select(obsID, _INSERT)

schema_bayas2021 <-
  setFormat(header = _INSERT, decimal = _INSERT, thousand = _INSERT,
            na_values = _INSERT) |>
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "externalID", columns = _INSERT) |>
  setIDVar(name = "disclosed", type = "l", value = _INSERT) |>
  setIDVar(name = "date", columns = _INSERT) |>
  setIDVar(name = "irrigated", type = "l", value = _INSERT) |>
  setIDVar(name = "present", type = "l", value = _INSERT) |>
  setIDVar(name = "sample_type", value = "visual interpretation") %>%
  setIDVar(name = "collector", value = "citizen scientist") %>%
  setIDVar(name = "purpose", value = "study") %>%
  setObsVar(name = "concept", type = "c", columns = _INSERT) #"Forests"

temp <- reorganise(schema = schema_bayas2021, input = data)


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
