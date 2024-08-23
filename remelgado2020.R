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
# doi/url     : https://doi.org/10.1038/s41597-020-00591-2, https://doi.org/10.6084/m9.figshare.12047478
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

thisDataset <- "Remelgado2020"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "Land cover is a key variable in the context of climate change. In particular, crop type information is essential to understand the spatial distribution of water usage and anticipate the risk of water scarcity and the consequent danger of food insecurity. This applies to arid regions such as the Aral Sea Basin (ASB), Central Asia, where agriculture relies heavily on irrigation. Here, remote sensing is valuable to map crop types, but its quality depends on consistent ground-truth data. Yet, in the ASB, such data are missing. Addressing this issue, we collected thousands of polygons on crop types, 97.7% of which in Uzbekistan and the remaining in Tajikistan. We collected 8,196 samples between 2015 and 2018, 213 in 2011 and 26 in 2008. Our data compile samples for 40 crop types and is dominated by “cotton” (40%) and “wheat”, (25%). These data were meticulously validated using expert knowledge and remote sensing data and relied on transferable, open-source workflows that will assure the consistency of future sampling campaigns.",
              homepage = "https://doi.org/10.1038/s41597-020-00591-2, https://doi.org/10.6084/m9.figshare.12047478",
              version = "2021.09",
              licence_link = _INSERT,
              reference = read.bib(paste0(thisDir, "10.1038_s41597-020-00591-2-citation.ris")))

new_source(name = thisDataset, date = ymd("2021-09-14"), ontology = path_onto_occurr)


message(" --> handling data")
data_path <- paste0(dir_input, "CAWa_CropType_samples.shp")
data <- st_read(dsn = data_path) %>%
  as_tibble()


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
# newConcepts <- tibble(target = c("cotton", "wheat", NA,
#                                  "Tree orchards", "rice", "VEGETABLES",
#                                  "maize", "alfalfa", "melon",
#                                  "Grapes", "Fallow", "sorghum",
#                                  NA, "soybean", "barley",
#                                  "carrot", "potato", "carrot",
#                                  "cabbage", "onion", "bean",
#                                  "sunflower", "tomato", "oat",
#                                  "potato", "pumpkin"),
#                       new = unique(data$label_1),
#                       class = c("commodity", "commodity", NA,
#                                 "land-use", "commodity", "group",
#                                 "commodity", "commodity", "commodity",
#                                 "group", "land-use", "commodity",
#                                 NA, "commodity", "commodity",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "commodity", "commodity",
#                                 "commodity", "commodity"
#                       ),
#                       description = "",
#                       match = "close",
#                       certainty = 3)
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
