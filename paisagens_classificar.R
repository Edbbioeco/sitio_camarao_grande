# Pacotes ----

library(terra)

library(tidyverse)

library(tidyterra)

library(DescTools)

library(ggview)

# Rasters ----

## Importar ----

rasters <- purrr::map(list.files(path = "./rgb",
                                 full.names = TRUE),
                      terra::rast) |>
  setNames(list.files(path = "./rgb",
                      full.names = TRUE) |>
             stringr::str_remove_all("./rgb/|.tif"))
