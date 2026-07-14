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
    \(periodo) {

      tryCatch({

        arq <- "mapbiomas_local.tif"

        download.file(
          paste0(
            "https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_",
            periodo,
            ".tif"
          ),
          arq,
          mode = "wb"
        )

        r <- terra::rast(arq) |>
          terra::crop(sitio) |>
          terra::mask(sitio)

        file.remove(arq)

        r

      }, error = \(e) {

        message("Erro no ano ", periodo, ": ", e$message)
        NULL

        }

      )

      }

    ), .progress = TRUE)


### Remover os NULL da lista ----

raster_uso_trat <- raster_uso |>
  purrr::compact()

raster_uso_trat
