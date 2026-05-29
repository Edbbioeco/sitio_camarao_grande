# Pacotes ----

library(sf)

library(tidyverse)

library(CDSE)

library(rsi)

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

evalscript <- rsi::spectral_indices() |>
  dplyr::filter(short_name == "NDVI") |>
  CDSE::MakeEvalScript(constellation = "landsat") |>
  paste(collapse = "\n")

evalscript

## Períodos ----

periodos <- catalogo |>
  dplyr::mutate(ano = acquisitionDate |> lubridate::year(),
                mes = acquisitionDate |> lubridate::month(),
                ano_mes = paste0(ano,
                                 "-",
                                 mes)) |>
  dplyr::group_by(mes, ano) |>
  dplyr::slice_head() |>
  dplyr::arrange(ano, mes) |>
  as.data.frame() |>
  dplyr::pull(acquisitionDate)

periodos

## Baixar rasters ----

dir.create("./ndvi")

purrr::map(periodos, \(periodo){

  CDSE::GetImage(bbox = scg |> sf::st_bbox(),
                 time_range = periodo,
                 script = evalscript,
                 file = paste0("./ndvi/ndvi_", periodo, ".tif"),
                 collection = "sentinel-2-l2a",
                 format = "image/tiff",
                 mosaicking_order = "leastCC",
                 resolution = 20,
                 mask = FALSE,
                 buffer = 100,
                 client = OAuthClient)
  },
  .progress = TRUE)

# Mapas ----

## Importar rasters ----

rasters <- purrr::map(list.files(path = "./ndvi/",
                                 full.names = TRUE),
                      terra::rast) |>
  setNames(list.files(path = "./ndvi/",
                      full.names = TRUE) |>
             stringr::str_remove_all("./ndvi/|.tif"))

rasters

## Visualizar ----

nomes <- rasters |> names()

nomes

purrr::map2(rasters, nomes, \(raster, nome){

  ggplot() +
    tidyterra::geom_spatraster(data = raster) +
    scale_fill_gradientn(colours = c("#3A0603",
                                     "#F08650",
                                     "#FFFD55",
                                     "#A1FA4F",
                                     "#377E47"),
                         limits = c(-1, 1)) +
    geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
    labs(title = nome,
         fill = "NDVI")

  },
  .progress = TRUE)

## Exportar ----

mapas <- purrr::map2(rasters, nomes, \(raster, nome){

  ggplot() +
    tidyterra::geom_spatraster(data = raster) +
    scale_fill_gradientn(colours = c("#3A0603",
                                     "#F08650",
                                     "#FFFD55",
                                     "#A1FA4F",
                                     "#377E47"),
                         limits = c(-1, 1)) +
    geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
    labs(title = nome,
         fill = "NDVI") +
    coord_sf(expand = FALSE) +
    theme_minimal() +
    theme(axis.text = element_text(color = "black", size = 20),
          legend.text = element_text(color = "black", size = 20),
          legend.title = element_text(color = "black", size = 20),
          plot.title = element_text(color = "black", size = 20))

  },
  .progress = TRUE)

dir.create("./mapas_ndvi")

purrr::map2(mapas,
            nomes,
            ~ ggsave(plot = .x,
                     filename = paste0("./mapas_ndvi/mapa_", .y, ".png"),
                     height = 10,
                     width = 12),
            .progress = TRUE)
