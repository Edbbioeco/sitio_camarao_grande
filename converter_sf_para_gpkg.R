# Pacotes ----

library(tidyverse)

library(sf)

# Converter sf para gpkg ----

## Lista de shapefiles ----

sfs <- list.files(pattern = ".shp$",
                  full.names = TRUE)

sfs

## Converter ----

purrr::map(sfs,
           purrr::in_parallel(
             \(shp){

               sf <- sf::st_read(shp)

               sf |> sf::st_write(paste0("./",
                                         shp |>
                                           stringr::str_remove_all("./|.shp"),
                                         ".gpkg"))

               }
           ),
           .progress = TRUE)
