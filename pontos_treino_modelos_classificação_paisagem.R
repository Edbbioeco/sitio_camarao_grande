# Pacotes ----

library(sf)

library(tidyverse)

library(leaflet)

library(leaflet.extras)

library(leafem)

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

## Gerar os pontos ----

### Vegetação nativa ----

veg_nat <- mapa |>
  mapedit::editMap(targetGroup = "Draw",
                   polylineOptions = TRUE,
                   polygonOptions = TRUE,
                   circleOptions = TRUE,
                   rectangleOptions = TRUE,
                   markerOptions = TRUE,
                   circleMarkerOptions = TRUE,
                   editOptions = leaflet.extras::editToolbarOptions())

veg_nat <- veg_nat$drawn |>
  dplyr::mutate(Classe = "Vegetação Nativa")

veg_nat

ggplot() +
  geom_sf(data = scg, color = "black") +
  geom_sf(data = veg_nat, color = "black")

### Área de plantação ----

plantacao <- mapa |>
  mapedit::editMap(targetGroup = "Draw",
                   polylineOptions = TRUE,
                   polygonOptions = TRUE,
                   circleOptions = TRUE,
                   rectangleOptions = TRUE,
                   markerOptions = TRUE,
                   circleMarkerOptions = TRUE,
                   editOptions = leaflet.extras::editToolbarOptions())

plantacao <- plantacao$drawn |>
  dplyr::mutate(Classe = "Plantação")

plantacao

ggplot() +
  geom_sf(data = scg, color = "black") +
  geom_sf(data = veg_nat, color = "darkgreen") +
  geom_sf(data = plantacao, color = "limegreen")

### Solo exposto ----

solo <- mapa |>
  mapedit::editMap(targetGroup = "Draw",
                   polylineOptions = TRUE,
                   polygonOptions = TRUE,
                   circleOptions = TRUE,
                   rectangleOptions = TRUE,
                   markerOptions = TRUE,
                   circleMarkerOptions = TRUE,
                   editOptions = leaflet.extras::editToolbarOptions())

solo <- solo$drawn |>
  dplyr::mutate(Classe = "Solo Exposto")

solo

ggplot() +
  geom_sf(data = scg, color = "black") +
  geom_sf(data = veg_nat, color = "darkgreen") +
  geom_sf(data = plantacao, color = "limegreen") +
  geom_sf(data = solo, color = "goldenrod")

### Corpos hídricos ----

corpos_hid <- mapa |>
  mapedit::editMap(targetGroup = "Draw",
                   polylineOptions = TRUE,
                   polygonOptions = TRUE,
                   circleOptions = TRUE,
                   rectangleOptions = TRUE,
                   markerOptions = TRUE,
                   circleMarkerOptions = TRUE,
                   editOptions = leaflet.extras::editToolbarOptions())

corpos_hid <- corpos_hid$drawn |>
  dplyr::mutate(Classe = "Corpos Hídricos")

corpos_hid

ggplot() +
  geom_sf(data = scg, color = "black") +
  geom_sf(data = veg_nat, color = "darkgreen") +
  geom_sf(data = plantacao, color = "limegreen") +
  geom_sf(data = solo, color = "goldenrod") +
  geom_sf(data = corpos_hid, color = "royalblue")

## Unir os pontos em um único shapefile ----

pontos_sh <- c("veg_nat",
               "plantacao",
               "solo",
               "corpos_hid") |>
  mget(envir = globalenv()) |>
  dplyr::bind_rows()

pontos_sh

### Exportar ----

pontos_sh |> sf::st_write("pontos_treino.shp")
