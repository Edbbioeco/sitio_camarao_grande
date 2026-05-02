# Pacotes ----

library(sf)

library(tidyverse)

library(maptiles)

library(tidyterra)

library(terra)

library(randomForest)

# Dados ----

## Shapefile do Sítio Camarão Grande ----

### Importar ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

scg

ggplot() +
  geom_sf(data = scg, color = "black")

## Shapefile de pontos de treino ----

### Importar ----

pontos <- sf::st_read("pontos_treino.shp")

### Visualizar ----

pontos

ggplot() +
  geom_sf(data = scg, color = "black") +
  geom_sf(data = pontos, aes(color = Classe))

## Imagem de satélite ----

### Baixar ----

scg_sat <- scg |>
  maptiles::get_tiles(provider = "Esri.WorldImagery",
                      zoom = 17)

### Visualizar ----

scg_sat

ggplot() +
  tidyterra::geom_spatraster_rgb(data = scg_sat) +
  geom_sf(data = scg, color = "gold", fill = "transparent") +
  geom_sf(data = pontos, aes(color = Classe)) +
  coord_sf(expand = FALSE)

# Modelo de classificação ----

## Valores dos pontos ----

valores <- scg_sat |>
  terra::extract(pontos) |>
  dplyr::mutate(ID = pontos$Classe) |>
  dplyr::rename("Classe" = ID) |>
  dplyr::mutate(Classe = Classe |> as.factor())

valores

## Criar io modelo ----

id <- 1:100

rodar_modelos <- function(id){

  modelo <- randomForest::randomForest(Classe ~ .,
                                       data = valores,
                                       ntree = 1000)

  assign(paste0("modelo_", id),
         modelo,
         envir = globalenv())

}

purrr::map(id, rodar_modelos)
