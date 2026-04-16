# pácotes ----

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

library(sf)

library(tidyverse)

# Criar o shapefile ----

## Ativar a interface interativa ----

mapa <- leaflet::leaflet() |>
  leaflet::addProviderTiles(provider = providers$Esri.WorldImagery) |>
  leaflet.extras::addDrawToolbar(targetGroup = "draw",
                                 polylineOptions = TRUE,
                                 polygonOptions = TRUE,
                                 circleOptions = TRUE,
                                 rectangleOptions = TRUE,
                                 markerOptions = TRUE,
                                 editOptions = leaflet.extras::editToolbarOptions()) |>
  leafem::addMouseCoordinates()

## Criar o shapefile ----

shapefile_sitio <- mapedit::editMap(mapa)

shapefile_sitio <- shapefile_sitio$drawn
