# Pacotes ----

library(geobr)

library(sf)

library(tidyverse)

library(maptiles)

library(tidyterra)

library(ggspatial)

library(ggview)

library(patchwork)

# Dados ----

## Shapefile do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2019)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br, color = "black")

## Shapefile de Pernambuco ----

### Filtrar ----

pe <- br |>
  dplyr::filter(abbrev_state == "PE")

### Visualizar ----

pe

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = pe, color = "black", fill = "goldenrod")

