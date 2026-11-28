# Pacotes ----

library(sf)

library(tidyverse)

library(rgee)

library(terra)

library(tidyterra)

library(magick)

library(landscapemetrics)

library(ggview)

library(gganimate)

# Shapefile do sítio ----

## Importar ----

sitio <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

sitio

ggplot() +
  geom_sf(data = sitio, color = "black", linewidth = 1)
