# Pacotes ----

library(sf)

library(tidyverse)

library(maptiles)

library(tidyterra)

library(terra)

library(randomForest)

library(ggspatial)

library(ggview)

# Dados ----

## Shapefile do Sítio Camarão Grande ----

### Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

### Visualizar ----

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

modelos <- purrr::map(id, \(id){

  modelo <- randomForest::randomForest(Classe ~ .,
                                       data = valores,
                                       ntree = 1500)

})

names(modelos) <- paste0("modelo_", id)

modelos

## Avaliar os modelos ----

df_valores <- modelos |>
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
                                "Corpos Hídricos" = "royalblue"),
                     breaks = c("OOB",
                                "Vegetação Nativa",
                                "Plantação",
                                "Solo Exposto",
                                "Corpos Hídricos")) +
  scale_fill_manual(values = c("OOB" = "black",
                                "Vegetação Nativa" = "darkgreen",
                                "Plantação" = "limegreen",
                                "Solo Exposto" = "goldenrod",
                                "Corpos Hídricos" = "royalblue"),
                    breaks = c("OOB",
                               "Vegetação Nativa",
                               "Plantação",
                               "Solo Exposto",
                               "Corpos Hídricos")) +
  theme_classic() +
  theme(axis.text = element_text(size = 17.5, color = "black"),
        axis.title = element_text(size = 17.5, color = "black"),
        legend.text = element_text(size = 17.5, color = "black"),
        legend.title = element_text(size = 17.5, color = "black"),
        legend.position = "bottom")

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

id <- 1:10

scg_class <- purrr::map(id, \(id){

  scg_classificado <- terra::predict(scg_sat_crop,
                                     escolhido_modelo)

  }) |>
  terra::rast()

names(scg_class) <- paste0("scg_class_", id)

scg_class

moda <- function(x){

  ux <- unique(x)

  ux <- ux[!is.na(ux)]

  ux[match(x, ux) |>
       tabulate() |>
       which.max()]

}

scg_ensemble <- terra::app(scg_class, moda)

terra::set.cats(scg_ensemble,
                value =  scg_class[[1]] |> terra::levels())

scg_ensemble

ggplot() +
  tidyterra::geom_spatraster_rgb(data = scg_sat) +
  tidyterra::geom_spatraster(data = scg_ensemble) +
  geom_sf(data = scg, color = "red", fill = "transparent") +
  coord_sf(expand = FALSE) +
  scale_fill_manual(values = c("Vegetação Nativa" = "darkgreen",
                               "Plantação" = "limegreen",
                               "Solo Exposto" = "goldenrod",
                               "Corpos Hídricos" = "royalblue"),
                    na.translate = FALSE)

# Mapa ----

ggplot() +
  tidyterra::geom_spatraster_rgb(data = scg_sat) +
  tidyterra::geom_spatraster(data = scg_ensemble) +
  geom_sf(data = scg,
          aes(color = "Sítio Camarão Grande"),
          fill = "transparent",
          linewidth = 1) +
  coord_sf(expand = FALSE) +
  scale_fill_manual(values = c("Vegetação Nativa" = "darkgreen",
                               "Plantação" = "limegreen",
                               "Solo Exposto" = "goldenrod4",
                               "Corpos Hídricos" = "royalblue"),
                    breaks = c("Vegetação Nativa",
                               "Plantação",
                               "Solo Exposto",
                               "Corpos Hídricos"),
                    na.translate = FALSE) +
  scale_color_manual(values = c("red")) +
  guides(color = guide_legend(order = 1)) +
  coord_sf(xlim = c(-35.48161, -35.47193),
           ylim = c(-8.42396, -8.409975),
           expand = FALSE,
           label_graticule = "SEW") +
  labs(color = NULL,
       fill = NULL,
       title = "Sítio Camarão Grande",
       subtitle = "Classificação do uso e cobertura do solo") +
  scale_x_continuous(breaks = seq(-35.480, -35.472, 0.004)) +
  ggspatial::annotation_scale(text_cex = 2.5,
                              text_col = "gold",
                              location = "bl",
                              bar_cols = c("black", "gold"),
                              line_width = 2,
                              height = unit(0.5, "cm")) +
  theme_minimal() +
  theme(axis.text = element_text(size = 17.5, color = "black"),
        legend.text = element_text(size = 17.5, color = "black"),
        legend.position = "bottom",
        plot.title = element_text(size = 17.5, color = "black"),
        plot.subtitle = element_text(size = 15, color = "black")) +
  ggview::canvas(height = 12, width = 12)

ggsave(filename = "uso_cobertura_solo.png",
       height = 12, width = 12)
