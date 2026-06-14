# Pacotes ----

library(tidyverse)

library(terra)

library(tidyterra)

library(DescTools)

library(ggview)

# Rasters ----

## RGB ----

### Importar ----

rgb <- purrr::map(list.files(path = "./rgb",
                                 pattern = ".tif$",
                                 full.names = TRUE),
                      terra::rast) |>
  setNames(list.files(path = "./rgb",
                      pattern = ".tif$",
                      full.names = TRUE) |>
             stringr::str_remove_all("./rgb/|.tif"))

### Visualizar ----

purrr::map2(rgb,
            rgb |> names(),
            ~ ggplot() +
              tidyterra::geom_spatraster_rgb(data = .x) +
              labs(title = .y))

## NDVI ----

# Classificação ----

## Importar o modelo ----

modelo <- readr::read_rds("modelo_randomforest_sentinell.rds")

modelo

## Gerar múltiplas predições ----

predicoes <- purrr::map(rasters,
                        purrr::in_parallel(

                          \(raster){

                            purrr::map(1:5, \(rep){

                              raster <- raster |> terra::subset(-4)

                              names(raster) <- rownames(modelo$importance)

                              terra::predict(raster, modelo)

                              },
                              .progress = TRUE)

                            }

                          ),
                        .progress = TRUE)

predicoes

## Calcular o consenso ----

consensos <- purrr::map(predicoes,
                        purrr::in_parallel(

                          ~terra::app(x = .x |> terra::rast(),
                                               DescTools::Mode)

                          ),
                        .progress = TRUE)

consensos

## Visualizar predições ----

purrr::map(consensos,
           ~ggplot() +
             tidyterra::geom_spatraster(data = .x) +
             scale_fill_viridis_c(),
           .progress = TRUE)
