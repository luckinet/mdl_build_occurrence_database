# ----
# title       : build occurrence database
# description : This is the main script for building a database of occurrence/in-situ data for all land-use dimensions of LUCKINet.
# license     : https://creativecommons.org/licenses/by-sa/4.0/
# authors     : Peter Pothmann, Steffen Ehrmann, Caterina Barasso
# date        : 2024-03-27
# version     : 0.7.0
# status      : working (luts)
# comment     : file.edit(paste0(dir_docs, "/documentation/04_build_occurrence_database.md"))
# ----

check out all the other european countries that are not yet in "EuroCrops/Schneider2023": https://agridata.ec.europa.eu/extensions/iacs/iacs.html
check this for more training data on palm oil: https://arxiv.org/pdf/2405.09530

# set module-specific paths ----
#
dir_onto <- .get_path("onto")
dir_onto_data <- .get_path("onto", "_data")
dir_occurr <- .get_path("occu")
dir_occurr_data <- .get_path("occu", "_data")

path_onto <- paste0(dir_onto_data, "lucki_onto.rds")
path_onto_occurr <- paste0(dir_occurr_data, "_meta/lucki_onto.rds")

# start database and set some meta information ----
#
adb_init(root = dir_occurr_data, version = paste0(model_name, model_version),
         staged = FALSE,
         licence = "https://creativecommons.org/licenses/by-sa/4.0/",
         ontology = list("use" = path_onto, "cover" = path_onto),
         author = list(cre = model_info$authors$cre,
                       aut = model_info$authors$aut$occurrence,
                       ctb = model_info$authors$ctb$occurrence))

# build database ----
#
# source(paste0(dir_occurr, "agris2018.R"))
# source(paste0(dir_occurr, "alemayehu2019.R"))
# source(paste0(dir_occurr, "aleza2018.R"))
# source(paste0(dir_occurr, "amir1991.R"))
# source(paste0(dir_occurr, "anderson-teixeira2014.R"))
# source(paste0(dir_occurr, "anderson-teixeira2018.R"))
# source(paste0(dir_occurr, "anderson2003.R"))
# source(paste0(dir_occurr, "annighöfer2015.R"))
# source(paste0(dir_occurr, "asigbaase2019.R"))
# source(paste0(dir_occurr, "auscovera.R"))
# source(paste0(dir_occurr, "auscoverb.R"))
# source(paste0(dir_occurr, "ausplots.R"))
# source(paste0(dir_occurr, "bagchi2017.R"))
# source(paste0(dir_occurr, "ballauff2021.R"))
source(paste0(dir_occurr, "bastin2017.R"))
# source(paste0(dir_occurr, "batjes2021.R"))
source(paste0(dir_occurr, "bayas2017.R"))
source(paste0(dir_occurr, "bayas2021.R"))
# source(paste0(dir_occurr, "beenhouwer2013.R"))
# source(paste0(dir_occurr, "beyrs2015.R"))
# source(paste0(dir_occurr, "bigearthnet.R"))
# source(paste0(dir_occurr, "biodivinternational.R"))
# source(paste0(dir_occurr, "biota.R"))
# source(paste0(dir_occurr, "biotime.R"))
# source(paste0(dir_occurr, "bisseleua2013.R"))
# source(paste0(dir_occurr, "blaser2018.R"))
# source(paste0(dir_occurr, "bocquet2019.R"))
# source(paste0(dir_occurr, "bordin2021.R"))
# source(paste0(dir_occurr, "borer2019.R"))
# source(paste0(dir_occurr, "bosch2008.R"))
# source(paste0(dir_occurr, "bright2019.R"))
# source(paste0(dir_occurr, "broadbent2021.R"))
# source(paste0(dir_occurr, "bücker2010.R"))
# source(paste0(dir_occurr, "budburst.R"))
# source(paste0(dir_occurr, "caci.R"))
# source(paste0(dir_occurr, "californiaCrops.R"))
# source(paste0(dir_occurr, "camara2019.R"))
# source(paste0(dir_occurr, "camara2020.R"))
# source(paste0(dir_occurr, "capaverde2018.R"))
# source(paste0(dir_occurr, "caughlin2016.R"))
# source(paste0(dir_occurr, "cawa.R"))
# source(paste0(dir_occurr, "crain2018.R"))
# source(paste0(dir_occurr, "coleman2008.R"))
# source(paste0(dir_occurr, "conrad2019.R"))
# source(paste0(dir_occurr, "chain-guadarrama2017.R"))
# source(paste0(dir_occurr, "craven2018.R"))
source(paste0(dir_occurr, "cropharvest.R"))
# source(paste0(dir_occurr, "crowther2019.R"))
# source(paste0(dir_occurr, "cv4a.R"))
# source(paste0(dir_occurr, "dataman.R"))
# source(paste0(dir_occurr, "davila-lara2017.R"))
# source(paste0(dir_occurr, "deblécourt2017.R"))
# source(paste0(dir_occurr, "declercq2012.R"))
# source(paste0(dir_occurr, "degroote2019.R"))
# source(paste0(dir_occurr, "dejonge2014.R"))
# source(paste0(dir_occurr, "descals2020.R"))
# source(paste0(dir_occurr, "desousa2020.R"))
# source(paste0(dir_occurr, "doughty2015.R"))
# source(paste0(dir_occurr, "drakos2020.R"))
# source(paste0(dir_occurr, "dutta2014.R"))
# source(paste0(dir_occurr, "esc.R"))
# source(paste0(dir_occurr, "ehbrecht2021.R"))
source(paste0(dir_occurr, "ehrmann2017.R"))
# source(paste0(dir_occurr, "empres.R"))
source(paste0(dir_occurr, "eurosat.R"))
# source(paste0(dir_occurr, "falster2015.R"))
# source(paste0(dir_occurr, "fang2021.R"))
# source(paste0(dir_occurr, "faye2019.R"))
# source(paste0(dir_occurr, "feng2022.R"))
# source(paste0(dir_occurr, "firn2020.R"))
# source(paste0(dir_occurr, "flores-moreno2017.R"))
# source(paste0(dir_occurr, "forestgeo.R"))
# source(paste0(dir_occurr, "franklin2015.R"))
# source(paste0(dir_occurr, "franklin2018.R"))
source(paste0(dir_occurr, "fritz2017.R"))
# source(paste0(dir_occurr, "gafc.R"))
# source(paste0(dir_occurr, "gallhager2017.R"))
source(paste0(dir_occurr, "garcia2022.R"))
# source(paste0(dir_occurr, "gashu2021.R"))
# source(paste0(dir_occurr, "gbif.R"))
# source(paste0(dir_occurr, "gebert2019.R"))
# source(paste0(dir_occurr, "genesys.R"))
source(paste0(dir_occurr, "gfsad30.R"))
# source(paste0(dir_occurr, "gibson2011.R"))
# source(paste0(dir_occurr, "glato2017.R"))
# source(paste0(dir_occurr, "globe.R"))
source(paste0(dir_occurr, "gofc-gold.R"))
# source(paste0(dir_occurr, "grosso2013.R"))
# source(paste0(dir_occurr, "grump.R"))
# source(paste0(dir_occurr, "guitet2015.R"))
# source(paste0(dir_occurr, "gyga.R"))
# source(paste0(dir_occurr, "haarhoff2019.R"))
# source(paste0(dir_occurr, "habel2020.R"))
# source(paste0(dir_occurr, "haeni2016.R"))
# source(paste0(dir_occurr, "hardy2019.R"))
# source(paste0(dir_occurr, "hengl2020.R"))
# source(paste0(dir_occurr, "hilpold2018.R"))
# source(paste0(dir_occurr, "hoffman2019.R"))
# source(paste0(dir_occurr, "hogan2018.R"))
# source(paste0(dir_occurr, "hudson2016.R"))
# source(paste0(dir_occurr, "hunt2013.R"))
# source(paste0(dir_occurr, "hylander2018.R"))
# source(paste0(dir_occurr, "infys.R"))
# source(paste0(dir_occurr, "ingrisch2014.R"))
# source(paste0(dir_occurr, "iscn.R"))
# source(paste0(dir_occurr, "jackson2021.R"))
# source(paste0(dir_occurr, "jin2021.R"))
source(paste0(dir_occurr, "jolivot2021.R"))
# source(paste0(dir_occurr, "jonas2020.R"))
# source(paste0(dir_occurr, "jordan2020.R"))
# source(paste0(dir_occurr, "juergens2012.R"))
# source(paste0(dir_occurr, "jung2016.R"))
# source(paste0(dir_occurr, "karlsson2017.R"))
# source(paste0(dir_occurr, "kebede2019.R"))
# source(paste0(dir_occurr, "kenefic2015.R"))
# source(paste0(dir_occurr, "kenefic2019.R"))
# source(paste0(dir_occurr, "kim2020.R"))                   | this may be problematic because apparently the coordinates indicate only a region, not the actual plots
# source(paste0(dir_occurr, "knapp2021.R"))
# source(paste0(dir_occurr, "kormann2018.R"))
# source(paste0(dir_occurr, "koskinen2018.R"))
# source(paste0(dir_occurr, "krause2021.R"))                | only peatland -> but this is def. also needed and it is part of the ontology
# source(paste0(dir_occurr, "lamond2014.R"))
# source(paste0(dir_occurr, "landpks.R"))
# source(paste0(dir_occurr, "lauenroth2019.R"))
# source(paste0(dir_occurr, "lasky2015.R"))
# source(paste0(dir_occurr, "ledig2019.R"))
# source(paste0(dir_occurr, "ledo2019.R"))
# source(paste0(dir_occurr, "leduc2021.R"))
source(paste0(dir_occurr, "lesiv2020.R"))
# source(paste0(dir_occurr, "li2018.R"))
# source(paste0(dir_occurr, "llorente2018.R"))
source(paste0(dir_occurr, "lpis_austria.R"))
source(paste0(dir_occurr, "lpis_czechia.R"))
source(paste0(dir_occurr, "lpis_denmark.R"))
source(paste0(dir_occurr, "lpis_estonia.R"))
source(paste0(dir_occurr, "lpis_latvia.R"))
source(paste0(dir_occurr, "lpis_slovakia.R"))
source(paste0(dir_occurr, "lpis_slovenia.R"))
source(paste0(dir_occurr, "lucas.R"))
# source(paste0(dir_occurr, "maas2015.R"))
# source(paste0(dir_occurr, "mandal2016.R"))
# source(paste0(dir_occurr, "mapbiomas.R"))
# source(paste0(dir_occurr, "marin2013.R"))                 | conversion of coordinates to decimal needed
# source(paste0(dir_occurr, "martinezsanchez2024.R"))
# source(paste0(dir_occurr, "mchairn2014.R"))
# source(paste0(dir_occurr, "mchairn2021.R"))
# source(paste0(dir_occurr, "mckee2015.R"))
# source(paste0(dir_occurr, "meddens2017.R"))
# source(paste0(dir_occurr, "mendoza2016.R"))
# source(paste0(dir_occurr, "merschel2014.R"))
# source(paste0(dir_occurr, "mgap.R"))
# source(paste0(dir_occurr, "mitchard2014.R"))
# source(paste0(dir_occurr, "moghaddam2014.R"))
# source(paste0(dir_occurr, "monro2017.R"))
# source(paste0(dir_occurr, "moonlight2020.R"))
# source(paste0(dir_occurr, "nalley2020.R"))
# source(paste0(dir_occurr, "nthiwa2020.R"))                | some meta-data missing
# source(paste0(dir_occurr, "nyirambangutse2017.R"))
# source(paste0(dir_occurr, "ofsa.R"))
# source(paste0(dir_occurr, "ogle2007.R"))
# source(paste0(dir_occurr, "oldfield2018.R"))
# source(paste0(dir_occurr, "oliva2020.R"))
# source(paste0(dir_occurr, "osm.R"))                       | where is the folder?
# source(paste0(dir_occurr, "osuri2019.R"))
# source(paste0(dir_occurr, "oswald2016.R"))
# source(paste0(dir_occurr, "ouedraogo2016.R"))
# source(paste0(dir_occurr, "pärn2018.R"))
# source(paste0(dir_occurr, "pennington.R"))
# source(paste0(dir_occurr, "perrino2012.R"))
# source(paste0(dir_occurr, "piponiot2016.R"))
# source(paste0(dir_occurr, "plantvillage.R"))
# source(paste0(dir_occurr, "ploton2020.R"))
# source(paste0(dir_occurr, "potapov2021.R"))
# source(paste0(dir_occurr, "quisehuatl-medina2020.R"))
# source(paste0(dir_occurr, "raley2017.R"))
# source(paste0(dir_occurr, "raman2006.R"))
# source(paste0(dir_occurr, "ramos-fabiel2018.R"))          | coordinates and target variable seems to be missing?!
# source(paste0(dir_occurr, "ratnam2019.R"))
# source(paste0(dir_occurr, "raymundo2018.R"))
# source(paste0(dir_occurr, "reiner2018.R"))
source(paste0(dir_occurr, "remelgado2020.R"))
# source(paste0(dir_occurr, "rineer2021.R"))
# source(paste0(dir_occurr, "robichaud2017.R"))
# source(paste0(dir_occurr, "roman2021.R"))
source(paste0(dir_occurr, "rpg_france.R"))
source(paste0(dir_occurr, "rußwurm2020.R"))
# source(paste0(dir_occurr, "samples.R"))
# source(paste0(dir_occurr, "sanches2018.R"))
# source(paste0(dir_occurr, "sanchez-azofeita2017.R"))
source(paste0(dir_occurr, "schepaschenko.R"))
# source(paste0(dir_occurr, "schneider2020.R"))
# source(paste0(dir_occurr, "schooley2005.R"))
# source(paste0(dir_occurr, "schulze2020.R"))
# source(paste0(dir_occurr, "schulze2023.R"))
source(paste0(dir_occurr, "see2016.R"))
source(paste0(dir_occurr, "see2022.R"))
# source(paste0(dir_occurr, "sen4cap.R"))
# source(paste0(dir_occurr, "seo2014.R"))
# source(paste0(dir_occurr, "shooner2018.R"))
# source(paste0(dir_occurr, "silva2019.R"))
# source(paste0(dir_occurr, "sinasson2016.R"))
# source(paste0(dir_occurr, "splot.R"))                     | clarify which values to use
# source(paste0(dir_occurr, "srdb.R"))
source(paste0(dir_occurr, "stanimirova2023.R"))
# source(paste0(dir_occurr, "stevens2011.R"))
# source(paste0(dir_occurr, "sullivan2018.R"))
# source(paste0(dir_occurr, "surendra2021.R"))
source(paste0(dir_occurr, "szantoi2020.R"))
source(paste0(dir_occurr, "szantoi2021.R"))
# source(paste0(dir_occurr, "szyniszewska2019.R"))
# source(paste0(dir_occurr, "tateishi2014.R"))
# source(paste0(dir_occurr, "tedonzong2021.R"))
# source(paste0(dir_occurr, "teixeira2015.R"))
# source(paste0(dir_occurr, "thornton2014.R"))
# source(paste0(dir_occurr, "trettin2017.R"))               | some metadata missing
# source(paste0(dir_occurr, "truckenbrodt2017.R"))
# source(paste0(dir_occurr, "vanhooft2015.R"))              | meta-data missing
# source(paste0(dir_occurr, "vieilledent2016.R"))
# source(paste0(dir_occurr, "vijay2016.R"))
# source(paste0(dir_occurr, "vilanova2018.R"))
# source(paste0(dir_occurr, "weber2011.R"))                 | meta-data missing
# source(paste0(dir_occurr, "wei2018.R"))
# source(paste0(dir_occurr, "wenden2016.R"))
# source(paste0(dir_occurr, "westengen2014.R"))
# source(paste0(dir_occurr, "wood2016.R"))
# source(paste0(dir_occurr, "woollen2017.R"))
# source(paste0(dir_occurr, "wortmann2019.R"))
# source(paste0(dir_occurr, "wortmann2020.R"))
# source(paste0(dir_occurr, "zhang1999.R"))

# 98. scrutinise issue and make a decision:
#
## time periods missing ----
# source(paste0(dir_occurr, "adina2017.R"))
# source(paste0(dir_occurr, "alvarez-davila2017.R")) 200 -forest- needs clarification (mail)
# source(paste0(dir_occurr, "bauters2019.R"))        15 -forest-
# source(paste0(dir_occurr, "chaudhary2016.R"))      1008 -forest-
# source(paste0(dir_occurr, "döbert2017.R"))         180 -forest-
# source(paste0(dir_occurr, "draper2021.R"))         1240 -forest-
# source(paste0(dir_occurr, "ibanez2018.R"))         434 -forest-
# source(paste0(dir_occurr, "ibanez2020.R"))         51 -forest-
# source(paste0(dir_occurr, "keil2019.R"))
# source(paste0(dir_occurr, "lewis2013.R"))          260 -forest-
# source(paste0(dir_occurr, "menge2019.R"))          44 -forest-
# source(paste0(dir_occurr, "morera-beita2019.R"))   20 -forest-
# source(paste0(dir_occurr, "parizzi2017.R"))
# source(paste0(dir_occurr, "potts2017.R"))
# source(paste0(dir_occurr, "sankaran2007.R"))       854 -forest-
# source(paste0(dir_occurr, "sarti2020.R"))
# source(paste0(dir_occurr, "scarcelli2019.R"))      168 -yam-
# source(paste0(dir_occurr, "trettin2020.R"))        17 -mangrove-
# source(paste0(dir_occurr, "zhao2014.R"))           2897 -cropland-
#
## hard to get data ----
# source(paste0(dir_occurr, "ma2020.R")) read data from pdf
# source(paste0(dir_occurr, "timesen2crop.R")) coordinates not readily available
#
## data need to be sampled from GeoTiff ----
# source(paste0(dir_occurr, "wcda.R"))
# source(paste0(dir_occurr, "xu2020.R"))
# https://github.com/corentin-dfg/Satellite-Image-Time-Series-Datasets

## final decision reached (here only with reason for exclusion) ----
sort into "03 build occurrence database.md"
# Sheils2019      missing cor now in contact authors
# OBrian2019      missing cor of plots --> moved to discarded
# Waha2016        no explicit spatial data available that go beyond admin level 2 of the GADM dataset
# wang2020        only experiment site coordinates, not on plot level - has many grazing data with coordinates and dates available
# liangyun2019    this is a reinterpretation of GOFC-GOLD and GFSAD30 datasets to the LCCS, which is thus unsuitable for us, since we'd have to reinterpret the reinterpretation, when we can instead work with GOFC-GOLD --> no it is more then that i think, they also use water LC data of WWF, do u want me to put it to review?
# reetsch2020     coordinates of farms (houshold survey) not the actual fields
# conabio         this seems to be primarily on the number of plant occurrences, and I don't see a way to easily extract information on landcover or even land use
# schneider2023   the data are not primary data, so we decided to download the primary data instead (in the lpis* sctips)
