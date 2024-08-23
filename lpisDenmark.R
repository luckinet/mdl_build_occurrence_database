# ----
# title       : build occurrence database - lpis Denmark
# description : this script integrates data of 'landbrugs' (https://landbrugsgeodata.fvm.dk/)
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Steffen Ehrmann
# date        : 2024-07-10
# version     : 0.8.0
# status      : done
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md")); due to the size of the data, I have to deviate from the default outline of this script.
# ----
# doi/url     : https://landbrugsgeodata.fvm.dk/
# license     : _INSERT
# geography   : _INSERT
# spatial     : _INSERT
# period      : 2008 - 2024
# variables   :
# - cover     : _INSERT
# - use       : _INSERT
# sampling    : _INSERT
# purpose     : _INSERT
# data type   : areal
# features    : _INSERT
# ----

thisDataset <- "lpisDenmark"
message("\n---- ", thisDataset, " ----")

message(" --> handling metadata")
thisDir <- paste0(dir_occurr_wip, "data/", thisDataset, "/")

regDataseries(name = thisDataset,
              description = "The Danish Agriculture Agency works to create value for agriculture on a sustainable basis. Through grants, regulation and control, we set the framework for a competitive profession where growth and jobs benefit the entire country.",
              homepage = "https://landbrugsgeodata.fvm.dk/",
              version = "2024-04-29",
              licence_link = "unclear",
              reference = read.bib(paste0(thisDir, "ref.bib")))

new_source(name = thisDataset, date = ymd("2024-04-29"), ontology = path_onto_odb)


message(" --> handling data")
files <- list.files(thisDir, pattern = "zip")
prevNr <- 0


theConcepts <- tibble(concept = character())
for(i in seq_along(files)){

  subset <- str_split(files[i], "[.]")[[1]][1]
  theDate <- str_split(subset, "_")[[1]][2]
  file.remove(list.files(paste0(thisDir, "temp"), full.names = T))

  message(" ---- year ", theDate, " ----")
  message("   --> reading in data")
  unzip(exdir = paste0(thisDir, "temp"), zipfile = paste0(thisDir, subset, ".zip"))

  inData <- st_read(dsn = list.files(paste0(thisDir, "temp/"), pattern = "shp", full.names = TRUE), quiet = TRUE, options = "ENCODING=ISO-8859-1") |>
    st_transform(crs = 4326) |>
    st_make_valid()

  data <- inData |>
    mutate(date = theDate) |>
    mutate(obsID = row_number()+prevNr, .before = 1) |>
    filter(!is.na(Afgroede)) |>
    as_tibble()
  prevNr <- prevNr + dim(data)[1]

  geom <- data |>
    select(obsID, geometry)

  data <- data |>
    st_drop_geometry()

  other <- data |>
    select(-Afgroede, -date)

  message("   --> normalizing data")
  temp <- data |>
    mutate(datasetID = thisDataset,
           disclosed = TRUE,
           present = TRUE,
           sample_type = "field",
           collector = "expert", # the farmers
           purpose = "monitoring")

  if(any(colnames(temp) == "Ansoeger")){
    temp <- temp |>
      unite(col = externalID, Marknr, Ansoeger, sep = "_", remove = FALSE)
  } else {
    temp <- temp |>
      mutate(externalID = Marknr)
  }
  temp <- temp |>
    select(datasetID, obsID, externalID, disclosed, date, present, sample_type, collector, purpose, concept = Afgroede)


  message("   --> harmonizing with ontology")
  out <- matchOntology(table = temp,
                       columns = "concept",
                       colsAsClass = FALSE,
                       groupMatches = TRUE,
                       dataseries = thisDataset,
                       ontology = path_onto_odb)
  # out <- temp
  # theConcepts <- temp |>
  #   select(concept) |>
  #   mutate(!!sym(theDate) := TRUE) |>
  #   distinct() |>
  #   left_join(theConcepts, by = "concept")

  out <- out |>
    left_join(geom, by = "obsID")

  message("   --> writing output")
  st_write(obj = out, dsn = paste0(dir_occurr_out, thisDataset, "_", theDate, ".gpkg"))
  saveRDS(object = other, file = paste0(dir_occurr_out, thisDataset, "_", theDate, "_other.rds"))
}

beep(sound = 10)
message("\n     ... done")

