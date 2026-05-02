# Pacotes ----

library(sf)

library(tidyverse)

library(maptiles)

library(tidyterra)

library(terra)

library(randomForest)

# Dados ----

## Shapefile do Sítio Camarão Grande ----

### Importar ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

scg

ggplot() +
  geom_sf(data = scg, color = "black")

## Shapefile de pontos de treino ----

### Importar ----

pontos <- sf::st_read("pontos_treino.shp")

### Visualizar ----

pontos

ggplot() +
  geom_sf(data = scg, color = "black") +
  geom_sf(data = pontos, aes(color = Classe))
