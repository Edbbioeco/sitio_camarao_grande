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
