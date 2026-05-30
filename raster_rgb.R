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

evalscript <- CDSE::MakeEvalScript(list(bands = c("R", "G", "B"),
                                        formula = "0.3 * R + 0.59 * G + 0.11 * B",
                                        platforms = "Sentinel-2"),
                                   constellation = "sentinel-2") |>
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

dir.create("./rgb")

purrr::map(periodos, \(periodo){

  CDSE::GetImage(bbox = scg |> sf::st_bbox(),
                 time_range = periodo,
                 script = evalscript,
                 file = paste0("./rgb/rbg_", periodo, ".tif"),
                 collection = "sentinel-2-l2a",
                 format = "image/tiff",
                 mosaicking_order = "leastCC",
                 resolution = 10,
                 mask = TRUE,
                 buffer = 100,
                 client = OAuthClient

                 )},
  .progress = TRUE)

# Mapas ----

## Importar rasters ----

rasters <- purrr::map(list.files(path = "./rgb/",
                                 full.names = TRUE),
                      terra::rast) |>
  setNames(list.files(path = "./ndvi/",
                      full.names = TRUE) |>
             stringr::str_remove_all("./ndvi/|.tif"))

rasters
