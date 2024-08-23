# ----
# title       : build occurrence database - _INESRT
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-04-17
# version     : 0.0.0
# status      : done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://doi.org/10.1594/PANGAEA.873912
# license     : _INSERT
# geography   : Global
# period      : 2016
# variables   :
#  - cover    : VEGETATED
#  - use      : cropland
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 203516
# ----

thisDataset <- "bayas2017"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "A global reference dataset on cropland was collected through a crowdsourcing campaign implemented using Geo-Wiki. This reference dataset is based on a systematic sample at latitude and longitude intersections, enhanced in locations where the cropland probability varies between 25-75% for a better representation of cropland globally. Over a three week period, around 36K samples of cropland were collected. For the purpose of quality assessment, additional datasets are provided. One is a control dataset of 1793 sample locations that have been validated by students trained in image interpretation. This dataset was used to assess the quality of the crowd validations as the campaign progressed. Another set of data contains 60 expert or gold standard validations for additional evaluation of the quality of the participants. These three datasets have two parts, one showing cropland only and one where it is compiled per location and user. This reference dataset will be used to validate and compare medium and high resolution cropland maps that have been generated using remote sensing. The dataset can also be used to train classification algorithms in developing new maps of land cover and cropland extent",
              homepage = "https://doi.org/10.1594/PANGAEA.873912",
              version = "2021.09",
              licence_link = "https://creativecommons.org/licenses/by/3.0/",
              reference = read.bib(paste0(thisDir, "Crowdsource_cropland.bib")))

new_source(name = thisDataset, date = ymd("2021-09-13"), ontology = path_onto_occurr)



message(" --> handling data")
data_path <- paste0(thisDir, "loc_all.txt")

data <- read_tsv(file = data_path)

# schema_bayas2017 <-
#   setIDVar(name = "datasetID", value = thisDataset) %>%
#   setIDVar(name = "open", type = "l", value = TRUE) %>%
#   setIDVar(name = "type", value = "point") %>%
#   setIDVar(name = "x", type = "n", columns = 6) %>%
#   setIDVar(name = "y", type = "n", columns = 7) %>%
#   setIDVar(name = "epsg", value = "") %>%


message("   --> normalizing data")
data <- data %>%
  mutate(obsID = row_number(), .before = 1) |>
  separate_wider_delim(cols = "timestamp", delim = " ", names = "date", too_many = "drop") |>
  mutate(concept = "Cropland") |>
  st_as_sf(coords = c("centroid_X", "centroid_Y"), crs = 4326)

geom <- data |>
  select(obsID, geometry)
data <- data |>
  st_drop_geometry()

other <- data %>%
  select(obsID, sumcrop)

schema_bayas2017 <-
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) %>%
  setIDVar(name = "externalID", columns = 2) %>%
  setIDVar(name = "disclosed", type = "l", value = TRUE) |>
  setIDVar(name = "date", type = "D", columns = 4) %>%
  setIDVar(name = "irrigated", type = "l", value = FALSE) %>%
  setIDVar(name = "present", type = "l", value = TRUE) %>%
  setIDVar(name = "sample_type", value = "visual interpretation") %>%
  setIDVar(name = "collector", value = "citizen scientist") %>%
  setIDVar(name = "purpose", value = "validation") %>%
  setObsVar(name = "concept", type = "c", columns = 6)

temp <- reorganise(schema = schema_bayas2017, input = data)


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
