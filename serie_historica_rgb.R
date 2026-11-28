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

    colecao <- ee$ImageCollection("COPERNICUS/S2_SR_HARMONIZED")$
      filterBounds(rgee::sf_as_ee(sitio)$geometry())$
      filterDate(periodo, fim)$
      linkCollection(ee$ImageCollection("GOOGLE/CLOUD_SCORE_PLUS/V1/S2_HARMONIZED"),
                     list("cs_cdf"))$
      map(\(imagem){

        imagem$updateMask(imagem$select("cs_cdf")$gte(0.6))

        })

    if(colecao$size()$getInfo() == 0){

      return(NULL)

    }

    url <- colecao$
      select(c("B2", "B3", "B4", "B8"))$
      median()$
      getDownloadURL(
        list(
          region = rgee::sf_as_ee(sitio)$geometry(),
          scale = 10,
          crs = "EPSG:4326",
          format = "GEO_TIFF"
        )
      )

    arquivo <- tempfile(fileext = ".tif")

    download.file(url, arquivo, mode = "wb", quiet = TRUE)

    terra::rast(arquivo) |>
      setNames(c("blue", "green", "red", "nir")) |>
      terra::mask(sitio) |>
      terra::toMemory()

  },
  .progress = TRUE) |>
  setNames(meses |> stringr::str_sub(1, 7)) |>
  purrr::compact()

## Visuaizar ----

raster_satelite

purrr::imap(
  raster_satelite,
  \(raster, data){

    ggplot() +
      tidyterra::geom_spatraster_rgb(data = raster,
                                     r = 3, g = 2, b = 1,
                                     stretch = "lin") +
      labs(title = data)

  },
  .progress = TRUE)
