# devtools::install_github("cboettig/minioclient")

library(gbifdb)
library(tictoc)
library(dplyr)
library(minioclient)
# install_mc() Requis 

# Obtenir la version la plus récente 
gv = gbif_version()
# Chemin d'accès pour le fichier parquet
pathGBIF = '/Volumes/Disk_fun/gbif_data'
# Obtenir une étampe de temps 
date_download = Sys.time()
# Faire un nouveau dossier dans un disque de stockage 
# Vous pouvez le mettre localement, mais cela est assez imposant (>100GB)! 
dir.create(path = pathGBIF,
           showWarnings = FALSE)
mss = sprintf("## Information sur le téléchargement des données GBIF\n
Chemin d'accès GBIF : \t%1$s
Version GBIF :\t\t%2$s, 
Date téléchargement : \t%3$s
              ", 
              file.path(pathGBIF, "occurence", gv, "occurrence.parquet"), 
              gv,
              date_download
)

message(mss)

# 19h02 --> 02:41 (250GB)
# Téléchargement des données localement 
# gbif_download(
#   version = gv,
#   dir = pathGBIF
# )
gbif <- gbif_local(dir = "/Volumes/Disk_fun/gbif_data/occurrence/2025-06-01/occurrence.parquet")

names(gbif)

dset = gbif |> 
  count(datasetkey) |> 
  arrange(-n) |> 
  collect()
lic = gbif |> 
  count(license) |> 
  arrange(-n) |> 
  collect()

head_gbif = gbif |> 
  slice_head(n = 6) |> 
  collect()

# get GBIF data 
tictoc::tic() # 
df2 <- gbif |> 
  # dplyr::select(decimallatitude, 
  #               decimallongitude, 
  #               scientificname,
  #               taxonrank,
  #               phylum, 
  #               class, 
  #               order, 
  #               family, 
  #               genus,
  #               species, 
  #               infraspecificepithet, 
  #               individualcount,
  #               datasetkey,
  #               publishingorgkey,
  #               occurrencestatus,
  #               coordinateuncertaintyinmeters, 
  #               coordinateprecision, 
  #               identifiedby,
  #               basisofrecord,
  #               license,
  #               countrycode) |> 
  filter(
    datasetkey == '50c9509d-22c7-4a22-a47d-8c48425ef4a7', # iNaturalist Research-grade Observations, https://www.gbif.org/dataset/50c9509d-22c7-4a22-a47d-8c48425ef4a7
    countrycode == "CA",
    occurrencestatus == 'PRESENT', 
    basisofrecord == 'HUMAN_OBSERVATION'
  ) |> 
  collect() 
tictoc::toc()
