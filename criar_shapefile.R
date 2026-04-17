# pácotes ----

library(geobr)

library(tidyverse)

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

library(sf)

# Shapefile do município de Amaraji ----

## Importar ----

amaraji <- geobr::read_municipality() |>
  dplyr::filter(name_muni == "Amaraji")

## Visualizar ----

amaraji

ggplot() +
  geom_sf(data = amaraji)

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
  leafem::addMouseCoordinates(css = list("font-size" = "8px",
                                         "font-weight" = "bold",
                                         "padding" = "10px",
                                         "background-color" = "#ffffff",
                                         "color" = "#000000" )) |>
  leaflet::addPolygons(data = amaraji)

## Criar o shapefile ----

shapefile_sitio <- mapedit::editMap(mapa)

shapefile_sitio <- shapefile_sitio$drawn

## Visualizar ----

shapefile_sitio

ggplot() +
  geom_sf(data = shapefile_sitio)

## Exportar ----

shapefile_sitio |>
  sf::st_write("shapefile_sitio.shp")
