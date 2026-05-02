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

id <- 1:500

rodar_modelos <- function(id){

  modelo <- randomForest::randomForest(Classe ~ .,
                                       data = valores,
                                       ntree = 1500)

  assign(paste0("modelo_", id),
         modelo,
         envir = globalenv())

}

purrr::map(id, rodar_modelos)

## Avaliar os modelos ----

df_valores <- ls(pattern = "modelo_") |>
  mget(envir = globalenv()) |>
  purrr::imap(\(modelo, id){

    modelo$err.rate |>
      as.data.frame() |>
      dplyr::mutate(modelo_id = id,
                    ntree     = 1:nrow(modelo$err.rate))

  }) |>
  dplyr::bind_rows() |>
  dplyr::rename("N-Tree" = ntree)

df_valores

df_valores |>
  tidyr::pivot_longer(cols = 1:5,
                      names_to = "Error type",
                      values_to = "Error") |>
  dplyr::group_by(`N-Tree`, `Error type`) |>
  dplyr::summarise(mean  = mean(Error),
                   lower = min(Error),
                   upper = max(Error),
                   .groups = "drop") |>
  ggplot(aes(x = `N-Tree`,
                  color = `Error type`,
                  fill = `Error type`)) +
  geom_ribbon(aes(ymin = lower,
                  ymax = upper,
                  color = NULL),
              alpha = 0.3) +
  geom_line(aes(y = mean)) +
  labs(Y = "Error rate") +
  scale_x_continuous(breaks = seq(0, 1500, 100)) +
  scale_color_manual(values = c("OOB" = "black",
                                "Vegetação Nativa" = "darkgreen",
                                "Plantação" = "limegreen",
                                "Solo Exposto" = "goldenrod",
                                "Corpos Hídricos" = "royalblue")) +
  scale_fill_manual(values = c("OOB" = "black",
                                "Vegetação Nativa" = "darkgreen",
                                "Plantação" = "limegreen",
                                "Solo Exposto" = "goldenrod",
                                "Corpos Hídricos" = "royalblue")) +
  theme_classic() +
  theme(legend.position = "bottom")

## Escolher o melhor modelo ----

escolhido_modelo <- df_valores |>
  dplyr::group_by(modelo_id) |>
  dplyr::slice(1) |>
  dplyr::arrange(OOB) |>
  dplyr::select(OOB, modelo_id, `N-Tree`) |>
  dplyr::ungroup() |>
  dplyr::slice(1) |>
  dplyr::pull(modelo_id)

escolhido_modelo

## Exportar modelç ----

escolhido_modelo |>
  mget(envir = globalenv()) %>%
  .[[1]] |>
  saveRDS("modelo_randomforest.rds")

escolhido_modelo <- readRDS("modelo_randomforest.rds")

escolhido_modelo

## Recortar o raster ----

scg_sat_crop <- scg_sat |>
  terra::crop(scg) |>
  terra::mask(scg)

scg_sat_crop

ggplot() +
  tidyterra::geom_spatraster_rgb(data = scg_sat_crop) +
  geom_sf(data = scg, color = "gold", fill = "transparent") +
  geom_sf(data = pontos, aes(color = Classe)) +
  coord_sf(expand = FALSE)

## Testar e classificar ----

scg_class <- terra::predict(scg_sat_crop, escolhido_modelo)

scg_class

ggplot() +
  tidyterra::geom_spatraster_rgb(data = scg_sat) +
  geom_sf(data = scg, color = "red", fill = "transparent") +
  coord_sf(expand = FALSE) +
  scale_fill_manual(values = c("Vegetação Nativa" = "darkgreen",
                                "Plantação" = "limegreen",
                                "Solo Exposto" = "goldenrod",
                                "Corpos Hídricos" = "royalblue"),
                    na.translate = FALSE)

