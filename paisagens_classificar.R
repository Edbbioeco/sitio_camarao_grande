# Pacotes ----

library(tidyverse)

library(terra)

library(tidyterra)

library(DescTools)

library(ggview)

# Rasters ----

## Importar ----

rasters <- purrr::map(list.files(path = "./rgb",
                                 full.names = TRUE),
                      terra::rast) |>
  setNames(list.files(path = "./rgb",
                      full.names = TRUE) |>
             stringr::str_remove_all("./rgb/|.tif"))

## Visualizar ----

purrr::map2(rasters,
            rasters |> names(),
            ~ ggplot() +
              tidyterra::geom_spatraster_rgb(data = .x) +
              labs(title = .y))

# Classificação ----

## Importar o modelo ----

modelo <- readr::read_rds("modelo_randomforest.rds")

modelo

## Gerar múltiplas predições ----

predicoes <- purrr::map(rasters, \(raster){

  purrr::map(1:5, \(rep){

    raster <- raster |> terra::subset(-4)

    names(raster) <- rownames(modelo$importance)

    terra::predict(raster, modelo)

    },
    .progress = TRUE)

  },
  .progress = TRUE)

predicoes

## Calcular o consenso ----

consensos <- purrr::map(predicoes, ~terra::app(x = .x |> terra::rast(),
                                               DescTools::Mode),
                        .progress = TRUE)

consensos
