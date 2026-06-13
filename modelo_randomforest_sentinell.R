# PAcotes ----

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(randomForest)

# Dados ----

## Shapefile do sítio ----

### Importar ----

sitio <- sf::st_read("shapefile_sitio.shp")

### Visualizar ----

sitio

ggplot() +
  geom_sf(data = sitio)

## Pontos de treino ----

### Importar ----

pontos <- sf::st_read("pontos_treino.shp")

### Visualizar ----

pontos

ggplot() +
  geom_sf(data = sitio) +
  geom_sf(data = pontos, aes(color = Classe))

## Raster de treino ----

### Importar ----

raster <- terra::rast("./rgb/rbg_2019-11-24-2019-12-24.tif")

### Visualizar ----

raster

ggplot() +
  tidyterra::geom_spatraster_rgb(data = raster)

# Modelo ----

## Extrair os valores ----

valores <- raster |>
  terra::extract(pontos) |>
  dplyr::select(-1) |>
  dplyr::mutate(classe = pontos$Classe |> as.factor(),
                .before = red)

valores

valores |> dplyr::glimpse()

## Criar multiplos modelos ----

modelos <- purrr::map(1:500,
                      purrr::in_parallel(

                        ~randomForest::randomForest(classe ~ .,
                                                    data = valores,
                                                    ntree = 500)

                      ),
                      .progress = TRUE) |>
  setNames(paste0("modelo_", 1:500))

modelos

## Avaliar os modelos ----

df_modelos <- purrr::imap(modelos,
                          purrr::in_parallel(

                            ~.x$err.rate |>
                              as.data.frame() |>
                              dplyr::mutate(modelo_id = .y,
                                            ntree = 1:nrow(.x$err.rate))

                          ),
                          .progress = TRUE) |>
  dplyr::bind_rows() |>
  dplyr::rename("N-Tree" = ntree)

df_modelos
