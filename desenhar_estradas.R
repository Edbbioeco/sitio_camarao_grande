# Pacotes ----

library(sf)

library(tidyverse)

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

# Shapefile do sítio Camaraão Grande ----

## Importar ----

scg <- sf::st_read("shapefile_sitio.shp")
