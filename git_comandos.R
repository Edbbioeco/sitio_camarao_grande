# Pacotes ----

library(gert)

# Arquivos áptos ----

gert::git_status() |>
  as.data.frame()

# Adicionar arquivos ----

gert::git_add(files = "git_comandos.R")

# Commitar ----

gert::git_commit(message = "Script para comandos de Git")

# Pushar ----

gert::git_push(remote = "sitio")

# Pullar ----

gert::git_pull(remote = "sitio")

# Resetar ----

gert::git_reset_mixed()

gert::git_reset_soft()
