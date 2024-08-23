# ----
# title       : build occurrence database - _INESRT
# description : this script integrates data of '_INSERT' (LINK)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann
# date        : 2024-04-17
# version     : 1.0.0
# status      : done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----
# doi/url     : https://doi.org/10.5194/essd-13-3767-2021
# license     : _INSERT
# geography   : Sub-Saharan Africa and Carribean
# period      : 2000, 2005, 2010, 2015, 1016, 2020
# variables   :
# - cover     : various
# - use       : vegetated
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 43433
# ----

thisDataset <- "szantoi2021"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = "Natural resources are increasingly being threatened in the world. Threats to biodiversity and human well-being pose enormous challenges to many vulnerable areas. Effective monitoring and protection of sites with strategic conservation importance require timely monitoring with special focus on certain land cover classes which are especially vulnerable. Larger ecological zones and wildlife corridors warrant monitoring as well, as these areas have an even higher degree of pressure and habitat loss as they are not “protected” compared to Protected Areas (i.e. National Parks). To address such a need, a satellite-imagery-based monitoring workflow to cover at-risk areas was developed. During the program's first phase, a total of 560 442 km2 area in sub-Saharan Africa was covered. In this update we remapped some of the areas with the latest satellite images available, and in addition we added some new areas to be mapped. Thus, in this version we updated and mapped an additional 852 025km2 in the Caribbean, African and Pacific regions with up to 32 land cover classes. Medium to high spatial resolution satellite imagery was used to generate dense time series data from which the thematic land cover maps were derived. Each map and change map were fully verified and validated by an independent team to achieve our strict data quality requirements. Further details regarding the sites selection, mapping and validation procedures are described in the corresponding publication: Szantoi, Zoltan; Brink, Andreas; Lupi, Andrea (2021): An update and beyond: key landscapes for conservation land cover and change monitoring, thematic and validation datasets for the African, Caribbean and Pacific region (in review, Earth System Science Data/).",
              homepage = "https://doi.pangaea.de/10.1594/PANGAEA.931968",
              version = "2022.10",
              licence_link = "https://creativecommons.org/licenses/by/4.0/",
              reference = read.bib(paste0(thisDir, "dataset931968.bib")))

new_source(name = thisDataset, date = ymd("2022-10-18"), ontology = path_onto_occurr)


message(" --> handling data")
data_path_cmpr <- paste0(dir_input, "ALL_DATA_KLC_2.zip")
unzip(zipfile = data_path_cmpr, exdir = dir_input)
unzip(zipfile = paste0(dir_input, "ValidationData.zip"), exdir = dir_input)
#
files <- list.files(path =  paste0(dir_input, "/ValidationData/"),
                    pattern = ".shp$", full.names = TRUE)

data <-  map(.x = files, .f = function(ix){
  region <- str_split(tail(str_split(ix, "/")[[1]], 1), "[.]")[[1]][1]
  st_read(dsn = ix) |>
    st_make_valid() |>
    st_transform(crs = "EPSG:4326") |>
    mutate(region = region, .before = 1)
}) |>
  bind_rows()

message("   --> normalizing data")
# data <- data |>
#   bind_cols(st_coordinates(data)) |>
#   st_drop_geometry() |>
#   mutate(obsID = row_number(), .before = 1)
#
# other <- data |>
#   select(obsID, region)
#
# schema_szantoi2021 <-
#   setFormat(header = 1L) |>
#   setIDVar(name = "datasetID", value = thisDataset) |>
#   setIDVar(name = "obsID", type = "i", columns = 1) |>
#   setIDVar(name = "open", type = "l", value = TRUE) |>
#   setIDVar(name = "type", value = "point") |>
#   setIDVar(name = "x", type = "n", columns = 15) |>
#   setIDVar(name = "y", type = "n", columns = 16) |>
#   setIDVar(name = "epsg", value = "4326") |>
#   setIDVar(name = "date", columns = c(3:14), rows = 1, split = "(\\d+)") |>
#   setIDVar(name = "irrigated", type = "l", value = FALSE) |>
#   setIDVar(name = "present", type = "l", value = TRUE) |>
#   setIDVar(name = "sample_type", value = "visual interpretation") |>
#   setIDVar(name = "collector", value = "expert") |>
#   setIDVar(name = "purpose", value = "validation") |>
#   setObsVar(name = "concept", type = "c", columns = c(3:14), top = 1)

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
