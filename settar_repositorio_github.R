# Pacotes ----

library(usethis)

# Iniciar ----

usethis::use_git()

# Settar repositório ----

usethis::use_git_remote(url = "https://github.com/Edbbioeco/sitio_camarao_grande.git",
                        name = "sitio",
                        overwrite = TRUE)
