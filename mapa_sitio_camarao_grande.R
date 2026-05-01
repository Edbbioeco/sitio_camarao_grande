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

ggplot() +
  geom_sf(data = br, color = "black")
