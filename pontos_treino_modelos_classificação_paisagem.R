# Pacotes ----

library(sf)

library(tidyverse)

library(leaflet)

library(leaflet.extras)

library(mapedit)

# Shpefile do sítio ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

scg

ggplot() +
  geom_sf(data = scg, color = "black")
