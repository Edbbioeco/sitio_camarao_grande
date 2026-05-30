# Pacotes ----

library(sf)

library(tidyverse)

library(CDSE)

library(rsi)

library(terra)

library(tidyterra)

library(ggview)

# Shapefile da área ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

scg

ggplot() +
  geom_sf(data = scg, color = "black")
