# Pacotes ----

library(tidyverse)

library(sf)

# Converter sf para gpkg ----

## Lista de shapefiles ----

sfs <- list.files(pattern = ".shp$",
                  full.names = TRUE)

sfs
