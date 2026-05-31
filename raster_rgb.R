# Pacotes ----

library(sf)

library(tidyverse)

library(CDSE)

library(terra)

library(tidyterra)

library(ggview)

# Shapefile da área ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

scg

ggplot() +
  geom_sf(data = scg, color = "black")

# Baixar raster ----

## Autenticar usuário ----

OAuthClient <- CDSE::GetOAuthClient(id = Sys.getenv("CDSE_ID"),
                                    secret = Sys.getenv("CDSE_SECRET"))

OAuthClient

## Catálogo ----

catalogo <- CDSE::SearchCatalog(aoi = scg,
                                from = "2020-01-01", to = "2026-05-01",
                                collection = "sentinel-2-l2a",
                                with_geometry = FALSE,
                                client = OAuthClient)

catalogo

catalogo |> dplyr::glimpse()

## Evalscript ----

evalscript <- system.file("scripts",
                          "TrueColor.js",
                          package = "CDSE")

evalscript

## Períodos ----

periodos <- catalogo |>
  dplyr::mutate(ano = acquisitionDate |> lubridate::year(),
                mes = acquisitionDate |> lubridate::month(),
                ano_mes = paste0(ano,
                                 "-",
                                 mes)) |>
  dplyr::filter(tileCloudCover < 10) |>
  dplyr::group_by(mes, ano) |>
  dplyr::slice_min(tileCloudCover) |>
  dplyr::arrange(ano, mes) |>
  as.data.frame() |>
  dplyr::pull(acquisitionDate)

periodos

## Baixar rasters ----

unlink("./rgb", recursive = TRUE)

dir.create("./rgb")

purrr::map(periodos, \(periodo){

  CDSE::GetImage(bbox = scg |> sf::st_bbox(),
                 time_range = periodo,
                 script = evalscript,
                 file = paste0("./rgb/rbg_", periodo, ".tif"),
                 collection = "sentinel-2-l2a",
                 format = "image/tiff",
                 mosaicking_order = "leastRecent",
                 resolution = 10,
                 mask = TRUE,
                 buffer = 100,
                 client = OAuthClient)

  },
  .progress = TRUE)

# Mapas ----

## Importar rasters ----

rasters <- purrr::map(list.files(path = "./rgb/",
                                 pattern = ".tif$",
                                 full.names = TRUE),
                      terra::rast) |>
  setNames(list.files(path = "./rgb/",
                      pattern = ".tif$",
                      full.names = TRUE) |>
             stringr::str_remove_all("./rgb/|.tif"))

rasters

## Visualizar ----

nomes <- rasters |> names()

nomes

purrr::map2(rasters, nomes, \(raster, nome){

  ggplot() +
    tidyterra::geom_spatraster_rgb(data = raster) +
    geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
    scale_x_continuous(breaks = seq(-35.48256, -35.471, 0.005)) +
    labs(title = nome) +
    coord_sf(expand = FALSE) +
    theme_minimal() +
    theme(axis.text = element_text(color = "black", size = 20),
          plot.title = element_text(color = "black", size = 20)) +
    ggview::canvas(height = 10, width = 12)

  },
  .progress = TRUE)

## Exportar ----

mapas <- purrr::map2(rasters, nomes, \(raster, nome){

  ggplot() +
    tidyterra::geom_spatraster_rgb(data = raster) +
    geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
    scale_x_continuous(breaks = seq(-35.48256, -35.471, 0.005)) +
    labs(title = nome) +
    coord_sf(expand = FALSE) +
    theme_minimal() +
    theme(axis.text = element_text(color = "black", size = 20),
          plot.title = element_text(color = "black", size = 20))

  },
  .progress = TRUE)

dir.create("./mapas_rgb")

purrr::map2(mapas,
            nomes,
            ~ ggsave(plot = .x,
                     filename = paste0("./mapas_rgb/mapa_", .y, ".png"),
                     height = 10,
                     width = 12),
            .progress = TRUE)
