# Pacotes ----

library(sf)

library(tidyverse)

library(raster)

library(tidyterra)

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

# Dados ----

## Shapefile ----

### Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

### Visualizar ----

scg

ggplot() +
  geom_sf(data = scg)

## Raster ----

### Importar ----

rster_rg <- terra::rast("rgb/rbg_2019-11-24.tif")

### Visualizar ----

rster_rg

ggplot() +
  tidyterra::geom_spatraster_rgb(data = rster_rg) +
  geom_sf(data = scg, color = "red", fill = "transparent")
