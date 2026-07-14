# Pacotes ----

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggspatial)

library(ggview)

# Shapefile do sítio ----

## Importar ----

sitio <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

sitio

ggplot() +
  geom_sf(data = sitio, color = "black")

# Baixar e recortar rasters de uso e cobertura do solo ----

## Baixar ----

raster_uso <- purrr::map(
  1985:2025,
  purrr::in_parallel(

    tryCatch(
      \(periodo){

        download.file(
         paste0("https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_",
                periodo,
                ".tif"),
         "mapbiomas_local.tif",
         mode = "wb")

        terra::rast("mapbiomas_local.tif") |>
          terra::crop(sitio) |>
          terra::mask(sitio)

        file.remove("mapbiomas_local.tif")

    },
    error = \(e){})

    ),
  .progress = TRUE)
