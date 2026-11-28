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

