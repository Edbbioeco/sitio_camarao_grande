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

## Raster de RGB ----

### Importar ----

rgb <- terra::rast("./rgb/rbg_2019-11-24-2019-12-24.tif")

### Visualizar ----

rgb

ggplot() +
  tidyterra::geom_spatraster_rgb(data = rgb)

## Raster de NDVI ----

### Importar ----

ndvi <- terra::rast("./ndvi/ndvi_2019-11-24.tif")

### Visualizar ----

ndvi

ggplot() +
  tidyterra::geom_spatraster(data = ndvi) +
  scale_fill_viridis_c()

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

                        ~randomForest::randomForest(
                          classe ~ .,
                          data = valores |>
                            dplyr::filter(classe != "Corpos Hídricos") |>
                            droplevels(),
                          ntree = 1500
                          )

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

df_modelos |>
  tidyr::pivot_longer(cols = 1:4,
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
                                "Solo Exposto" = "goldenrod"),
                     breaks = c("OOB",
                                "Vegetação Nativa",
                                "Plantação",
                                "Solo Exposto")) +
  scale_fill_manual(values = c("OOB" = "black",
                               "Vegetação Nativa" = "darkgreen",
                               "Plantação" = "limegreen",
                               "Solo Exposto" = "goldenrod"),
                    breaks = c("OOB",
                               "Vegetação Nativa",
                               "Plantação",
                               "Solo Exposto")) +
  theme_classic() +
  theme(axis.text = element_text(size = 17.5, color = "black"),
        axis.title = element_text(size = 17.5, color = "black"),
        legend.text = element_text(size = 17.5, color = "black"),
        legend.title = element_text(size = 17.5, color = "black"),
        legend.position = "bottom")

## Escolher o melhor modelo ----

escolhido_modelo <- df_modelos |>
  dplyr::group_by(modelo_id) |>
  dplyr::slice(1) |>
  dplyr::arrange(OOB) |>
  dplyr::select(OOB, modelo_id, `N-Tree`) |>
  dplyr::ungroup() |>
  dplyr::slice(1) |>
  dplyr::pull(modelo_id)

escolhido_modelo

## Exportar modelo ----

modelos[[escolhido_modelo]] |>
  saveRDS("modelo_randomforest_sentinell.rds")

escolhido_modelo <- readRDS("modelo_randomforest_sentinell.rds")

escolhido_modelo
