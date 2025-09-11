library(dplyr)
library(duckdb)
library(duckdbfs)
library(sf)
library(h3)


source("http://atlas.biodiversite-quebec.ca/bq-atlas-parquet.R")

# Téléchargerment local 
# Remplacer « ~/Downloads » pour le répertoire de votre choix sur votre ordinateur.
dir.create(path = '/Volumes/Brainmemory/data/atlas_biodiv_qc', showWarnings = FALSE)
atlas <- atlas_local(parquet_date = tail(atlas_dates$dates,n=1),
                     destination_folder = '/Volumes/Brainmemory/data/atlas_biodiv_qc/')

head(atlas) |> as.data.frame()

sp_count_local <- atlas |> 
  filter(class == 'Aves') |> 
  group_by(valid_scientific_name) |> 
  summarize(cnt=count()) |> 
  arrange(desc(cnt)) |> 
  collect()

sp_aves <- atlas |> 
  filter(class == 'Aves') |> 
  collect()
nrow(sp_aves )




atlas_dates
atlas_rem <- atlas_remote(tail(atlas_dates$dates,n=1))
colnames(atlas_rem)
datasets <- atlas_rem |> group_by(dataset_name) |> summarize(cnt=count()) |> arrange(desc(cnt))
bubo_sca <- atlas_rem |> filter(valid_scientific_name == 'Bubo scandiacus') |> collect()
bubo_sca <- atlas_rem |> filter(valid_scientific_name == 'Bubo scandiacus') |> select(valid_scientific_name, latitude, longitude, 
dataset_name, year_obs, day_obs) |> collect()

iris_vers <- atlas_rem |> filter(valid_scientific_name == 'Iris versicolor') |> 
  mutate(geom = ST_Point(as.numeric(longitude), as.numeric(latitude))) |> 
  to_sf() |> collect()
plot(iris_vers)

sp_count <- atlas_rem |> group_by(valid_scientific_name) |> summarize(cnt=count()) |> arrange(desc(cnt)) |> collect()

