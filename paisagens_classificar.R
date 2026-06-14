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

rgb

purrr::imap(rgb,
            ~ ggplot() +
              tidyterra::geom_spatraster_rgb(data = .x) +
              labs(title = .y))

## NDVI ----

### Importar ----

ndvi <- purrr::map(list.files(path = "./ndvi/",
                              pattern = "2019-11-24|2025-03-24|2025-04-16|2025-11-07",
                              full.names = TRUE),
                   terra::rast) |>
  setNames(list.files(path = "./ndvi/",
                      pattern = "2019-11-24|2025-03-24|2025-04-16|2025-11-07") |>
             stringr::str_remove_all(".tif"))

### Visualizar ----

ndvi

purrr::imap(ndvi,
            ~ ggplot() +
              tidyterra::geom_spatraster(data = .x) +
              labs(title = .y) +
              scale_fill_viridis_c(limits = c(-1, 1)))

# Classificação ----

## Unir os rasters ----

raster_unido <- purrr::map2(rgb,
                            ndvi,
                            ~c(.x, .y))

raster_unido

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
