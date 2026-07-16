# Pacotes ----

library(sf)

library(tidyverse)

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

# Shapefile do sítio Camaraão Grande ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

scg

ggplot() +
  geom_sf(data = scg, color = "black")

# Desenhar shapefile da mapa ----

## Criar mapa interativo ----

mapa <- leaflet::leaflet(options = leaflet::leafletOptions(maxZoom = 22)) |>
  leaflet::addTiles(urlTemplate = "http://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",
                    options = leafletOptions(maxZoom = 22)) |>
  leaflet.extras::addDrawToolbar(
    targetGroup = "Draw",
    editOptions = leaflet.extras::editToolbarOptions()
  ) |>
  leafem::addMouseCoordinates() |>
  leaflet::addPolygons(data = scg,
                       color = "red",
                       fill = FALSE)

mapa

## Desenhar os polígonos ----

poligonos <- mapa |> mapedit::editMap()

### Visualizar os shapefiles ----

matas <- poligonos$finished

matas

ggplot() +
  geom_sf(data = matas, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = scg, color = "black", fill = "transparent")
