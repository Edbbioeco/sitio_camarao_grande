# Pacotes ----

library(sf)

library(tidyverse)

library(raster)

library(tidyterra)

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

# Dados ----

## Shapefile ----

### Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

### Visualizar ----

scg

ggplot() +
  geom_sf(data = scg)

## Raster ----

### Importar ----

raster_rg <- terra::rast("rgb/rbg_2019-11-24.tif")

### Visualizar ----

raster_rg

ggplot() +
  tidyterra::geom_spatraster_rgb(data = raster_rg) +
  geom_sf(data = scg, color = "red", fill = "transparent")

# Pontos de treino ----

## Mapa interativo ----

mapa_inter <- leaflet::leaflet() |>
  leaflet::addRasterImage(x = raster_rg) |>
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
                       color = "red",
                       fillOpacity = 0)

mapa_inter

## Pontos ----

### Vegetação nativa ----

veg_nat <- mapedit::editMap(mapa_inter)

veg_nat <- veg_nat$drawn |> dplyr::mutate(classe = "Vegetação Nativa")

veg_nat

### Plantação ----

plant <- mapedit::editMap(mapa_inter)

plant <- plant$drawn |> dplyr::mutate(classe = "Plantação")

plant

### Solo exposto ----

solo <- mapedit::editMap(mapa_inter)

solo <- solo$drawn |> dplyr::mutate(classe = "S0olo exposto")

solo
