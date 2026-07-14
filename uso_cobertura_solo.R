# Pacotes ----

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggspatial)

library(ggview)

# Shapefile do sítio ----

## Importar ----

sitio <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

sitio

ggplot() +
  geom_sf(data = sitio, color = "black")
