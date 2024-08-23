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
# doi/url     : https://doi.org/10.5194/essd-2020-77
# license     : _INSERT
# geography   : Sub-Saharan Africa
# period      : 2000, 2015 - 2017
# variables   :
#   - cover   : various
#   - use     : vegetated
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : point
# features    : 35927
# ----

thisDataset <- "szantoi2020"
message("\n---- ", thisDataset, " ----")

thisDir <- paste0(dir_occurr_data, thisDataset, "/")

message(" --> handling metadata")
regDataseries(name = thisDataset,
              description = _INSERT,
              homepage = _INSERT,
              version = _INSERT,
              licence_link = _INSERT,
              reference = read.bib(paste0(thisDir, "_INSERT.bib")))

new_source(name = thisDataset, date = ymd(_INSERT), ontology = path_onto_occurr)

new_reference(object = paste0(dir_input, "dataset914261.bib"),
              file = paste0(dir_occurr_wip, "references.bib"))

new_source(name = thisDataset,
           description = "Threats to biodiversity pose an enormous challenge for Africa. Mounting social and economic demands on natural resources increasingly threaten key areas for conservation. Effective protection of sites of strategic conservation importance requires timely and highly detailed geospatial monitoring. Larger ecological zones and wildlife corridors warrant monitoring as well, as these areas have an even higher degree of pressure and habitat loss. To address this, a satellite imagery based15 monitoring workflow to cover at-risk areas at various details was developed. During the program’s first phase, a total of 560,442km2 area in Sub-Saharan Africa was covered, from which 153,665km2 were mapped with 8 land cover classes while 406,776km2 were mapped with up to 32 classes. Satellite imagery was used to generate dense time series data from which thematic land cover maps were derived. Each map and change map were fully verified and validated by an independent team to achieve our strict data quality requirements. The independent validation datasets for each KLCs are also described and 20 presented here (The complete dataset available at Szantoi et al., 2020A https://doi.pangaea.de/10.1594/PANGAEA.914261, and a demonstration dataset at Szantoi et al., 2020B https://doi.pangaea.de/10.1594/PANGAEA.915849).",
           homepage = "https://doi.pangaea.de/10.1594/PANGAEA.914261",
           date = ymd("2021-09-14"),
           license = "https://creativecommons.org/licenses/by/4.0/",
           ontology = path_onto_odb)


message(" --> handling data")
data_path_cmpr <- paste0(dir_input, "ALL_DATA.zip")
unzip(exdir = dir_input, zipfile = data_path_cmpr)

files <- list.files(path = paste0(dir_input, "ALL_DATA/validationData_Sub-Sahara_Africa/"),
                    pattern = ".shp$", full.names = TRUE)

data <-  map(.x = files, .f = function(ix){
  region <- tail(str_split(ix, "/")[[1]], 1)
  st_read(dsn = ix) |>
    mutate(region = region, .before = 3)
}) |>
  bind_rows()


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

schema_szantoi2020 <-
  setFormat(header = 1L) |>
  setIDVar(name = "datasetID", value = thisDataset) |>
  setIDVar(name = "obsID", type = "i", columns = 1) |>
  setIDVar(name = "open", type = "l", value = TRUE) |>
  setIDVar(name = "type", value = "point") |>
  setIDVar(name = "x", type = "n", columns = 2) |>
  setIDVar(name = "y", type = "n", columns = 3) |>
  setIDVar(name = "epsg", value = "4326") |>
  setIDVar(name = "date", columns = c(5:8), rows = 1, split = "(\\d+)") |>
  setIDVar(name = "irrigated", type = "l", value = FALSE) |>
  setIDVar(name = "present", type = "l", value = TRUE) |>
  setIDVar(name = "sample_type", value = "field") |>
  setIDVar(name = "collector", value = "expert") |>
  setIDVar(name = "purpose", value = "study") |>
  setObsVar(name = "concept", type = "c", columns = c(5:8), top = 1)

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
