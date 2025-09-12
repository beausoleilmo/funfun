library(duckdb)
library(dplyr)
library(dbplyr)
library(tidyr) # gather
library(purrr) # map
library(stringr) # str_c
library(terra) # pour les images matricielles
library(viridisLite) # Palette de couleur viridis 

# Obtenir les données de GBIF directement. Sur le portail GBIF, j'ai filtrer toutes les données avec ceci (CAN.11_1 : c'est le Québec; OCCURRENCE_STATUS == present, donc pas une abscence!): 

# {
#   "type": "and",
#   "predicates": [
#     {
#       "type": "equals",
#       "key": "GADM_GID",
#       "value": "CAN.11_1",
#       "matchCase": false
#     },
#     {
#       "type": "equals",
#       "key": "OCCURRENCE_STATUS",
#       "value": "present",
#       "matchCase": false
#     }
#   ]
# }

# https://www.gbif.org/occurrence/download/0047252-250827131500795 # CSV
# https://www.gbif.org/occurrence/download/0049348-250827131500795 # DarwinCore Archive

# build/release/duckdb

con <- dbConnect(duckdb())
# Read the CSV into a DuckDB table named "gbif_data"
csv = "~/Bureau/gbif_data/0047252-250827131500795.csv"
# gbif_csv = duckdb_read_csv(conn = con, 
#                 # name = "gbif_data", 
#                 files = csv, 
#                 delim = '\t',   header = TRUE)

# This works... 
# csv= readr::read_delim("/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv", n_max = 2, delim = "\t")
# DBI::dbGetQuery(con, "select * from read_csv('/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv')")

# Generate a view 
# CREATE VIEW gb_data AS SELECT * FROM read_csv_auto('/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv')
DBI::dbExecute(con, sprintf("CREATE VIEW gb_data AS SELECT * FROM read_csv('%s', delim = '\t', quote='')", csv))

gb_dat = tbl(con, from = "gb_data")


# Count number of observations from iNaturalist Research-grade Observations
# See https://www.gbif.org/dataset/50c9509d-22c7-4a22-a47d-8c48425ef4a7
# dk_c = gb_dat |> 
#   count(datasetKey) |> 
#   arrange(-n) |> 
#   collect()

# Faire un raster avec les données GBIF (arrondir les coordonnées)
tictoc::tic() # 65 sec
df <- gb_dat |> 
  mutate(latitude = round(decimalLatitude, 2),
         longitude = round(decimalLongitude, 2)) |> 
  count(longitude, latitude) |> 
  collect() |> 
  mutate(n = log(n))
tictoc::toc()

dir.create(path = 'output/biodiv', showWarnings = FALSE, recursive = TRUE)
r <- rast(df, crs="epsg:4326")
# r = rast("output/biodiv/gbif_qc.tif")
# Afficher la 'densité' d'observation au Québec 
plot(r, 
     col = viridis(1e3), 
     legend=FALSE, maxcell=6e6, colNA="black", axes=FALSE)

# Exporter l'image matricielle 
writeRaster(x = r, 
            filename = "output/biodiv/gbif_qc.tif", 
            overwrite = TRUE)

# 50c9509d-22c7-4a22-a47d-8c48425ef4a7 : inat
tictoc::tic() # took 90 seconds on rusty iMac with linux 
inat_dat = gb_dat |> 
  filter(datasetKey == '50c9509d-22c7-4a22-a47d-8c48425ef4a7', 
         # prendre seulement les observations au niveau de l'espèce et plus précis
         taxonRank %in% c("SPECIES", "SUBSPECIES", "VARIETY")) |> 
  collect()
tictoc::toc()

# CSV out pour inat seulement fait environ 650MB (120MB compressé)
tictoc::tic() # took 30 seconds 
write.csv(x = inat_dat, 
          file = '~/Bureau/gbif_data/inat_research_grade_obs.csv', 
          row.names = FALSE)
tictoc::toc()


# Exploration données iNaturalist -----------------------------------------
# Lire les données fitrés 
inat_dat = read.csv(file = '~/Bureau/gbif_data/inat_research_grade_obs.csv')

unique(inat_dat$order)

inat_dat |> 
  count(taxonRank)
# Explore les valeurs uniques de manière efficace 
# https://stackoverflow.com/questions/57191886/show-unique-values-for-each-column
df2 <- inat_dat |> 
  # Extraire les colonnes 
  dplyr::select(where(is.character), # charactères et 
                # enlever les colonnes qui ne nous intéresse pas pour voir les valeurs uniques.
                -c(occurrenceID:species, scientificName, verbatimScientificName)) |> 
  # Ne trouver que les valeurs iunique dans chaque colonne et combiner les résultats avec ';', les résultats seront placées dans une liste 
  map(~str_c(unique(.x),collapse = ";")) |>  
  # Joindre toutes les rangées
  bind_rows() |> 
  # Replacer le jeu de données en format long 
  gather(key = col_name, value = col_unique) |>
  # Ne garder que les rangées qui n'ont colligé que des valeurs qui ne sont pas NA et un nombre résonable de caractères (moins de 1e3)
  filter(!is.na(nchar(col_unique)),
         nchar(col_unique) < 1e3 )

write.csv(x = df2, 
          file = "output/biodiv/unique_vals_inat_data.csv", 
          row.names = FALSE)



