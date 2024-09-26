# ----
# title       : build occurrence database
# description : This is the main script for building a database of occurrence/in-situ data for all land-use dimensions of LUCKINet.
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann, Caterina Barasso
# date        : 2024-03-27
# version     : 0.7.0
# status      : working (luts)
# comment     : file.edit(paste0(dir_docs, "/documentation/mdl_build_occurrence_database.md"))
# ----

# set module-specific paths ----
#
path_onto <- paste0(.get_path("onto", "_data"), "lucki_onto.rds")
path_onto_occurr <- paste0(.get_path("occu", "_data"), "_meta/lucki_onto.rds")

# start database and set some meta information ----
#
adb_init(root = .get_path("occu", "_data"), version = paste0(model_name, model_version),
         staged = FALSE,
         licence = "https://creativecommons.org/licenses/by-sa/4.0/",
         ontology = list("use" = path_onto, "cover" = path_onto),
         author = list(cre = model_info$authors$cre,
                       aut = model_info$authors$aut$occurrence,
                       ctb = model_info$authors$ctb$occurrence))


# build database ----
#
.run_submodules(model = model_info, module = "occu")

