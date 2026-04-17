# pácotes ----

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

library(tidyverse)

library(sf)

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
  leafem::addMouseCoordinates(css = list("font-size" = "12px",
                                         "font-weight" = "bold",
                                         "padding" = "10px",
                                         "background-color" = "#ffffff",
                                         "color" = "#000000" ))

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
