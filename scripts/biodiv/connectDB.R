library(DBI)
library(duckdb)
library(tidyverse)

con = duckdb()
bdbdqc = dbConnect(drv = con)
ttt = arrow::read_parquet('~/Desktop/gbif_CA_inat_lic_open_BY_animalia_2020plus_bboxQC.parquet')
inat_tbl <- dbGetQuery(conn = bdbdqc, "SELECT * FROM read_parquet('~/Desktop/gbif_CA_inat_lic_open_BY_animalia_2020plus_bboxQC.parquet')") |> 
  as_tibble()

nrow(inat_tbl)

ttt |>  distinct(license)
inat_tbl |>  distinct(license)

ttt |> count(kingdom, phylum, class, order)
inat_tbl |>  count(kingdom, phylum, class, order)
