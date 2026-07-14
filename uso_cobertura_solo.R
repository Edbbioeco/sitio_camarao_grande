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

    ), .progress = TRUE) |>
  setNames(1985:2025 |> as.character())


## Remover os NULL da lista ----

raster_uso_trat <- raster_uso |>
  purrr::compact()

raster_uso_trat

## Visualizar ----

purrr::imap(raster_uso_trat,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_viridis_c(option = "turbo",
                                     na.value = "transparent") +
                labs(title = .y)

           ),
           .progress = TRUE)

# Diversidade da paisagem ----

## Calcular diversidade ----

div_paisagem_shannon <- raster_uso_trat |>
  landscapemetrics::lsm_l_shdi() |>
  dplyr::mutate(Ano = raster_uso_trat |>
                  names() |>
                  as.numeric())

div_paisagem_shannon

div_paisagem_simpson <- raster_uso_trat |>
  landscapemetrics::lsm_l_sidi() |>
  dplyr::mutate(Ano = raster_uso_trat |>
                  names() |>
                  as.numeric())

div_paisagem_simpson

## Unir od data frames ----

df_div_paisagem <- dplyr::bind_rows(div_paisagem_shannon,
                                    div_paisagem_simpson)

df_div_paisagem

