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

## Pontos de treino ----

### Importar ----

pontos <- sf::st_read("pontos_treino.shp")

### Visualizar ----

pontos

ggplot() +
  geom_sf(data = sitio) +
  geom_sf(data = pontos, aes(color = Classe))

## Raster de treino ----

### Importar ----

raster <- terra::rast("./rgb/rbg_2019-11-24-2019-12-24.tif")

### Visualizar ----

raster

ggplot() +
  tidyterra::geom_spatraster_rgb(data = raster)
