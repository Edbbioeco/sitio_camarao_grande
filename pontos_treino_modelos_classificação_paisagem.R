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

# Pontos de treino ----

## Criar o mapa a ser editado ----

mapa <- leaflet::leaflet() |>
  leaflet::addProviderTiles(provider = providers$Esri.WorldImagery) |>
  leaflet.extras::addDrawToolbar(targetGroup = "Draw",
                                 polylineOptions = TRUE,
                                 polygonOptions = TRUE,
                                 circleOptions = TRUE,
                                 rectangleOptions = TRUE,
                                 markerOptions = TRUE,
                                 circleMarkerOptions = TRUE,
                                 editOptions = leaflet.extras::editToolbarOptions()) |>
  leafem::addMouseCoordinates() |>
  leaflet::addPolygons(data = scg,
                       color = "gold",
                       fillOpacity = 0)

mapa
