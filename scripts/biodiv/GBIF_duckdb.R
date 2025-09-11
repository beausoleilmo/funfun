library(duckdb)
library(dplyr)
con <- dbConnect(duckdb())
# Read the CSV into a DuckDB table named "gbif_data"
csv = "/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv"
gbif_csv = duckdb_read_csv(conn = con, 
                # name = "gbif_data", 
                files = csv, 
                delim = '\t',   header = TRUE)

# This works... 
# csv= readr::read_delim("/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv", n_max = 2, delim = "\t")
DBI::dbGetQuery(con, "select * from read_csv('/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv')")

# Generate a view 
# CREATE VIEW gb_data AS SELECT * FROM read_csv_auto('/Volumes/Disk_fun/gbif_data/0047252-250827131500795.csv')
DBI::dbExecute(con, sprintf("CREATE VIEW gb_data AS SELECT * FROM read_csv_auto('%s')", csv))

gb_dat = tbl(con, from = "gb_data")

# Count number of observations from iNaturalist Research-grade Observations
# See https://www.gbif.org/dataset/50c9509d-22c7-4a22-a47d-8c48425ef4a7
dk_c = gb_dat |> 
  count(datasetKey) |> 
  arrange(-n) |> 
  collect()

# 50c9509d-22c7-4a22-a47d-8c48425ef4a7 : inat
inat_dat = gb_dat |> 
  filter(datasetKey == '50c9509d-22c7-4a22-a47d-8c48425ef4a7') |> 
  collect()

# CSV out pour inat seulement fait environ 650MB (120MB compressé)
write.csv(x = inat_dat, 
          file = '/Volumes/Disk_fun/gbif_data/inat_research_grade_obs.csv', 
          row.names = FALSE)
