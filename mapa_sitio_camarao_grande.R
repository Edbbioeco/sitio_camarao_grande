# Pacotes ----

library(geobr)

library(sf)

library(tidyverse)

library(maptiles)

library(tidyterra)

library(ggmagnify)

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
                      zoom = 17)

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
          fill = "gray",
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
                          colour = "#8B0000",
                          proj.fill = "#8B00004D") +
  coord_sf(expand = FALSE,
           label_graticule = "NWS") +
  theme_void() +
  ggview::canvas(height = 10, width = 12)

mapa_br

## Mapa do sítio Camarão Grande ----

mapa_scg <- ggplot() +
  geom_sf(data = br,
          aes(color = "Brasil",
              fill = "Brasil"),
          linewidth = 0.75) +
  geom_sf(data = pe,
          aes(color = "Pernambuco",
              fill = "Pernambuco"),
          linewidth = 0.75) +
  geom_sf(data = amaraji,
          aes(color = "Amaraji",
              fill = "Amaraji"),
          linewidth = 1) +
  tidyterra::geom_spatraster_rgb(data = scg_sat) +
  geom_sf(data = scg,
          aes(color = "Sítio Camarão Grande",
              fill = "Sítio Camarão Grande"), linewidth = 2) +
  coord_sf(xlim = c(-35.48309, -35.46937),
           ylim = c(-8.426186, -8.409889),
           expand = FALSE,
           label_graticule = "NSEW") +
  ggspatial::annotation_scale(text_cex = 2.5,
                              text_col = "gold",
                              location = "br",
                              bar_cols = c("black", "gold"),
                              line_width = 2,
                              height = unit(0.5, "cm")) +
  scale_color_manual(values = c("Brasil" = "black",
                                "Pernambuco" = "black",
                                "Amaraji" = "darkgreen",
                                "Sítio Camarão Grande" = "red"),
                     breaks = c("Brasil",
                                "Pernambuco",
                                "Amaraji",
                                "Sítio Camarão Grande")) +
  scale_fill_manual(values = c("Brasil" = "gray",
                               "Pernambuco" = "gold",
                               "Amaraji" = "transparent",
                               "Sítio Camarão Grande" = "transparent"),
                     breaks = c("Brasil",
                                "Pernambuco",
                                "Amaraji",
                                "Sítio Camarão Grande")) +
  labs(color = NULL,
       fill = NULL) +
  scale_x_continuous(breaks = seq(-35.480, -35.472, 0.004)) +
  theme_minimal() +
  theme(axis.text = element_text(size = 17.5, color = "black"),
        legend.position = "bottom") +
  ggview::canvas(height = 10, width = 12)

mapa_scg

## Unir os mapas ----

cowplot::ggdraw(mapa_scg) +
  cowplot::draw_plot(mapa_br,
                     x = 0.2,
                     y = 0.1,
                     height = 0.325,
                     width = 0.325) +
  ggview::canvas(height = 10, width = 12)
