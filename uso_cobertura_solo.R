# Pacotes ----

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(magick)

library(landscapemetrics)

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

## Exportar os mapas ----

mapas_uso <- purrr::imap(raster_uso_trat,
                         purrr::in_parallel(

             ~ggplot() +
               tidyterra::geom_spatraster(data = .x) +
               scale_fill_viridis_c(option = "turbo",
                                    na.value = "transparent",
                                    guide = guide_colourbar(

                                      title.position = "top",
                                      title.hjust = 0.5,
                                      barwidth = 20,
                                      frame.colour = "black",
                                      ticks.colour = "black")

                                    ) +
               labs(title = paste0("Uso e cobertura do siolo para ", .y),
                    subtitle = "Fonte: MapBiomas",
                    fill = "Classe de uso e cobertura do solo") +
               theme_bw() +
               theme(axis.text = element_text(size = 20, color = "black"),
                     legend.text = element_text(size = 20, color = "black"),
                     legend.title = element_text(size = 20, color = "black"),
                     legend.position = "bottom",
                     strip.text = element_text(size = 30, color = "black"),
                     strip.background = element_rect(color = "black",
                                                     linewidth = 1),
                     panel.background = element_rect(linewidth = 1,
                                                     color = "black"),
                     plot.title = element_text(size = 20, color = "black"),
                     plot.subtitle = element_text(size = 17.5, color = "black"))

                         ),
                         .progress = TRUE)

mapas_uso

purrr::imap(mapas_uso,
            purrr::in_parallel(

             ~ggsave(.x,
                     filename = paste0("./mapas_uso_cobertura_solo/mapa_",
                                       .y,
                                       ".png"),
                     height = 10, width = 12)

             ),
            .progress = TRUE)

## Criar gif ----

### Importar as imagens ----

imagens_uso <- list.files(path = "./mapas_uso_cobertura_solo/",
                          pattern = "^mapa_",
                          full.names = TRUE) |>
  magick::image_read()

imagens_uso

### Gerar o gif ----

gif_uso <- imagens_uso |> magick::image_animate(fps = 1)

gif_uso

### Exportar gif ----

gif_uso |> magick::image_write("./mapas_uso_cobertura_solo/gif_uso_cobertura_solo.gif")

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
                                    div_paisagem_simpson) |>
  dplyr::mutate(metric = dplyr::case_when(

    metric == "shdi" ~ "Shannon-Wiener",
    .default = "Gini-Simpson"

  ))

df_div_paisagem

## Visualizar ----

df_div_paisagem |>
  ggplot(aes(Ano, value, color = metric)) +
  geom_line(linewidth = 1) +
  facet_wrap(~metric, ncol = 1, scales = "free_y") +
  scale_color_manual(values = c("gold4", "royalblue4")) +
  labs(y = "Diversidade da paisagem",
       color = NULL) +
  theme_bw() +
  theme(axis.text = element_text(size = 20, color = "black"),
        axis.title = element_text(size = 20, color = "black"),
        legend.text = element_text(size = 20, color = "black"),
        legend.title = element_text(size = 20, color = "black"),
        legend.position = "none",
        strip.text = element_text(size = 30, color = "black"),
        strip.background = element_rect(color = "black", linewidth = 1),
        panel.background = element_rect(linewidth = 1, color = "black")) +
  ggview::canvas(height = 10, width = 12)

ggsave(filename = "./mapas_uso_cobertura_solo/serie_temporal.png",
       height = 10, width = 12)

# Área de mata ----

## Códigos para área de mata ----

codigos <- c(1:6, 10:12, 29, 32, 49:50)

codigos

## Filtrar para as áreas de mata ----

raster_uso_trat_mata <- purrr::map(raster_uso_trat,
                                   purrr::in_parallel(

          ~.x |>
            tidyterra::mutate(

              mapbiomas_local = dplyr::case_when(

                mapbiomas_local %in% codigos ~ "Mata",
                .default = mapbiomas_local |> as.character()

              )

            ) |>
            tidyterra::filter(

              mapbiomas_local == "Mata")

          ),
          .progress = TRUE)

raster_uso_trat_mata

## Visualizar rasters filtrados ----

purrr::imap(raster_uso_trat_mata,
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = .x) +
                scale_fill_manual(values = c("Mata" = "forestgreen"),
                                  na.translate = FALSE) +
                labs(title = .y)

            ),
            .progress = TRUE)

## Exportar os mapss ----

mapas_uso_mata <- purrr::imap(raster_uso_trat_mata,
                              purrr::in_parallel(

          ~ggplot() +
            tidyterra::geom_spatraster(data = .x) +
            scale_fill_manual(values = c("Mata" = "forestgreen"),
                              na.translate = FALSE,
                              guide = guide_legend(

                                title.position = "top",
                                title.hjust = 0.5

                                )
                              ) +
            geom_sf(data = sitio, color = "black", fill = "transparent",
                    linewidth = 1) +
            labs(title = paste0("Área de mata do sítio Camarão Grande para ", .y),
                 subtitle = "Fonte: MapBiomas",
                 fill = NULL) +
            theme_bw() +
            theme(axis.text = element_text(size = 20, color = "black"),
                  legend.text = element_text(size = 20, color = "black"),
                  legend.title = element_text(size = 20, color = "black"),
                  legend.position = "bottom",
                  strip.text = element_text(size = 30, color = "black"),
                  strip.background = element_rect(color = "black", linewidth = 1),
                  panel.background = element_rect(linewidth = 1, color = "black"),
                  plot.title = element_text(size = 20, color = "black",
                                            hjust = 0.5),
                  plot.subtitle = element_text(size = 17.5, color = "black",
                                               hjust = 0.5))

          ),
          .progress = TRUE)

mapas_uso_mata

purrr::imap(mapas_uso_mata,
            purrr::in_parallel(

              ~ggsave(.x,
                      filename = paste0("./mapas_area_mata/mapa_",
                                        .y,
                                        ".png"),
                      height = 10, width = 12)

            ),
            .progress = TRUE)

## Criar gif ----

### Importar as imagens ----

imagens_mata <- list.files(path = "./mapas_area_mata/",
                           pattern = "^mapa_",
                           full.names = TRUE) |>
  magick::image_read()

imagens_mata

### Gerar o gif ----

gif_mata <- imagens_mata |> magick::image_animate(fps = 1)

gif_mata

## Área da mata ----

### Calcular área ----

areas_mata <- purrr::map_dbl(raster_uso_trat_mata,
                             purrr::in_parallel(

        ~.x |>
          terra::expanse(unit = "m") |>
          as.numeric() %>%
          .[2]

        ),
        .progress = TRUE)

areas_mata
