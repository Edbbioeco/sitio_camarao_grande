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

## Shapefile de Amaraji ----

### Importar ----

amaraji <- geobr::read_municipality() |>
  dplyr::filter(name_muni == "Amaraji")

### Visuazar ----

amaraji

ggplot() +
  geom_sf(data = pe, color = "black", fill = "goldenrod") +
  geom_sf(data = amaraji, color = "red", fill = "transparent")

## Shapefile do sítio Camarão Grande ----

### Importar ----

scg <- sf::st_read("shapefile_sitio.shp")

### Visualizar ----

scg

ggplot() +
  geom_sf(data = amaraji, color = "red", fill = "transparent") +
  geom_sf(data = scg, color = "red", fill = "transparent")

## Imagem de satélite do Sítio Camarão Grande ----

### Baixar ----

scg_sat <- scg |>
  maptiles::get_tiles(provider = "Esri.WorldImagery",
                      zoom = 17,
                      crop = TRUE)

### Visualizar ----

scg_sat

ggplot() +
  tidyterra::geom_spatraster_rgb(data = scg_sat) +
  geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
  coord_sf(expand = FALSE)

# Mapa ----

## Mapa do Brasil ----

mapa_br <- ggplot(data = br) +
  geom_sf(color = "black",
          linewidth = 0.75) +
  geom_sf(data = pe, color = "black", fill = "goldenrod",
          linewidth = 0.75) +
  geom_sf(data = amaraji, color = "darkgreen", fill = "transparent",
          linewidth = 1) +
  geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
  ggmagnify::geom_magnify(from = c(-35.56295,
                                   -35.37353,
                                   -8.456729,
                                   -8.261121),
                          to = c(-42,
                                 -42 + 0.18942*60,
                                 -33,
                                 -33 + 0.195608*60),
                          shape = "rect",
                          recompute = TRUE,
                          shadow = TRUE,
                          linewidth = 1,
                          expand = FALSE,
                          proj.fill = "#0000004D") +
  coord_sf(expand = FALSE,
           label_graticule = "NWS") +
  theme_minimal() +
  theme(axis.text = element_text(size = 17.5, color = "black")) +
  ggview::canvas(height = 10, width = 12)

mapa_br

## Mapa de Amaraji ----

mapa_pe <- ggplot() +
  geom_sf(data = pe, color = "black", fill = "goldenrod",
          linewidth = 0.75) +
  geom_sf(data = amaraji, color = "darkgreen", fill = "transparent",
          linewidth = 1) +
  geom_sf(data = scg, color = "red", fill = "transparent", linewidth = 1) +
  coord_sf(xlim = c(-35.56295, -35.37353),
           ylim = c(-8.456729, -8.261121),
           label_graticule = "SW") +
  theme_minimal() +
  theme(axis.text = element_text(size = 17.5, color = "black")) +
  ggview::canvas(height = 10, width = 12)

mapa_pe
