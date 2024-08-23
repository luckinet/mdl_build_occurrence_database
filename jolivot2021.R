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
# doi/url     : https://doi.org/10.5194/essd-13-5951-2021
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

thisDataset <- "jolivot2021"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "The availability of crop type reference datasets for satellite image classification is very limited for complex agricultural systems as observed in developing and emerging countries. Indeed, agricultural land use is very dynamic, agricultural censuses are often poorly georeferenced and crop types are difficult to interpret directly from satellite imagery. In this paper, we present a database made of 24 datasets collected in a standardized manner over nine sites within the framework of the international JECAM (Joint Experiment for Crop Assessment and Monitoring) initiative; the sites were spread over seven countries of the tropical belt, and the number of data collection years depended on the site (from 1 to 7 years between 2013 and 2020). These quality-controlled datasets are distinguished by in situ data collected at the field scale by local experts, with precise geographic coordinates, and following a common protocol. Altogether, the datasets completed 27074 polygons (20257 crops and 6817 noncrops, ranging from 748 plots in 2013 (one site visited) to 5515 in 2015 (six sites visited)) documented by detailed keywords. These datasets can be used to produce and validate agricultural land use maps in the tropics. They can also be used to assess the performances and robustness of classification methods of cropland and crop types/practices in a large range of tropical farming systems. The dataset is available at https://doi.org/10.18167/DVN1/P7OLAP (Jolivot et al., 2021).",
              homepage = "https://doi.org/10.5194/essd-13-5951-2021",
              version = "2022.01",
              licence_link = "https://creativecommons.org/licenses/by/4.0/",
              reference = read.bib(paste0(thisDir, "essd-13-5951-2021.bib")))

new_source(name = thisDataset, date = ymd("2022-01-22"), ontology = path_onto_occurr)


message(" --> handling data")
# data <- st_read(paste0(occurrenceDBDir, "00_incoming/", thisDataset, "/", "BD_JECAM_CIRAD_2021_dec_centroid.shp"))
# data1 <- st_coordinates(data) %>% as_tibble()
# data <- data %>%
#   st_drop_geometry() %>%
#   as_tibble() %>%
#   bind_cols(data1)

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
  setIDVar(name = "date", columns = _INSERT) |> # AcquiDate
  setIDVar(name = "irrigated", type = "l", value = _INSERT) |>
  setIDVar(name = "present", type = "l", value = _INSERT) |>
  setIDVar(name = "sample_type", value = _INSERT) |>
  setIDVar(name = "collector", value = _INSERT) |>
  setIDVar(name = "purpose", value = _INSERT) |>
  setObsVar(name = "concept", type = "c", columns = _INSERT) # CropType1, LandCover

temp <- reorganise(schema = schema_INSERT, input = data)


message("   --> harmonizing with ontology")
# matches <- tibble(new = unique(c(data$CropType1, data$CropType2, data$CropType3, data$LandCover)),
#                   old = c("Fallow", "Fallow", "cow pea", "peanut", "sorghum",
#                           "maize", "sesame", "rice", NA, "jatropha", "Fallow",
#                           "cotton", "Fallow", "millet", "soybean", "eucalyptus",
#                           "pea", "mango", NA, "Mixed cereals", "hibiscus",
#                           "okra", "cashew", NA, "FRUIT", NA, "ROOTS AND TUBERS",
#                           "VEGETABLES", "Fallow", "taro", "sapodilla", "tea",
#                           "coffee", "macadamia", "Flower herbs", "banana",
#                           "nappier grass", "Root or Bulb vegetables",
#                           "Woody flower crops", "Other Wooded Areas", "avocado",
#                           NA, NA, NA, NA, NA, NA, NA,
#                           NA, NA, "papaya", "sugarcane", "sunflower", "Grass and fodder crops",
#                           "sweet potato", "cassava", "Leafy or stem vegetables",
#                           "potato", "tomato", NA, "carrot", "bean", "cabbage",
#                           "oat", "onion", "Woody plantation", "Medicinal crops",
#                           "asparagus", "Sugar beet", "squash", "cucumber gherkin",
#                           "cucumber", "pineapple", "apple", "barley", "Oilseed crops",
#                           "pear", "Root or Bulb vegetables", "Fruit-bearing vegetables",
#                           "grape", "Mosaic of agricultural-uses", "peach", "Leguminous crops", "CEREALS",
#                           "orange", NA, "wheat", "Other vegetables", "watermelon", NA,
#                           "Citrus Fruit", "cauliflower broccoli", "Roots and Tubers",
#                           "eggplant", "guava", "Tree orchards", "cassava", NA,
#                           "Grass and fodder crops", "millet", "natural rubber",
#                           "hibiscus", "cashew", "Fibre crops", "Palm plantations",
#                           "mango", "Citrus Fruit", "lettuce", "cotton", "oil palm",
#                           NA, "Temporary cropland", "Permanent grazing",
#                           "Heterogeneous semi-natural areas", "Heterogeneous semi-natural areas",
#                           "ARTIFICIAL SURFACES", "Open spaces with little or no vegetation",
#                           "Forests", "WATER BODIES", "Heterogeneous semi-natural areas",
#                           "Heterogeneous semi-natural areas", "Open spaces with little or no vegetation",
#                           "Forests", "Shrubland", "Herbaceous associations",
#                           "Urban fabric", "Open spaces with little or no vegetation",
#                           "Herbaceous associations", "Open spaces with little or no vegetation",
#                           "WETLANDS", "FOREST AND SEMI-NATURAL AREAS"))
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
