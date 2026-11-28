# Pacotes ----

library(sf)

library(tidyverse)

library(rgee)

library(terra)

library(tidyterra)

library(magick)

library(landscapemetrics)

library(ggview)

library(gganimate)

# Shapefile do sítio ----

## Importar ----

sitio <- sf::st_read("shapefile_sitio.shp")

## Visualizar ----

sitio

ggplot() +
  geom_sf(data = sitio, color = "black", linewidth = 1)

# Imagens de satélite RGB ----

## Iniciar Google Earth Enginee ----

rgee::ee_Initialize(project = Sys.getenv("rgee_id"),
                    drive = TRUE)

## Settar imagens ----

meses <- seq(as.Date("2012-01-01"),
             lubridate::floor_date(Sys.Date(), "month") - months(1),
             by = "month") |>
  as.character()

meses

## Baixar imagens ----

raster_satelite <- purrr::map(
  meses,
  \(periodo){

    fim <- (as.Date(periodo) + months(1)) |> as.character()

    colecao <- ee$ImageCollection("LANDSAT/LE07/C02/T1_L2")$
      merge(ee$ImageCollection("LANDSAT/LC08/C02/T1_L2"))$
      merge(ee$ImageCollection("LANDSAT/LC09/C02/T1_L2"))$
      filterBounds(rgee::sf_as_ee(sitio)$geometry())$
      filterDate(periodo, fim)

    if(colecao$size()$getInfo() == 0){

      return(NULL)

    }

    url <- colecao$
      sort("CLOUD_COVER")$
      first()$
      select("SR_B.*")$
      getDownloadURL(
        list(
          region = rgee::sf_as_ee(sitio)$geometry(),
          scale = 30,
          crs = "EPSG:4326",
          format = "GEO_TIFF"
        )
      )

    arquivo <- tempfile(fileext = ".tif")

    download.file(url, arquivo, mode = "wb", quiet = TRUE)

    terra::rast(arquivo) |>
      terra::mask(sitio) |>
      terra::toMemory()

  },
  .progress = TRUE) |>
  setNames(meses |> stringr::str_sub(1, 7)) |>
  purrr::compact()

