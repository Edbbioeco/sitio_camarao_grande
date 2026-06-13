# PAcotes ----

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(randomForest)

# Dados ----

## Shapefile do sítio ----

### Importar ----

sitio <- sf::st_read("shapefile_sitio.shp")

### Visualizar ----

sitio

ggplot() +
  geom_sf(data = sitio)
