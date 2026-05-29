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
