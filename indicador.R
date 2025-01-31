library(dplyr)
library(readr)

datos <- read_csv2("datos/personal_academico_2008-2024.csv")
sedes <- read_csv2("datos/sedes_ed_superior_2024.csv")

datos

# las universidades no vienen georeferenciadas

datos |> distinct(tipo, variable)

datos2 <- datos |> 
  # distinct(codigo_ies, nombre_ies) |> 
  left_join(sedes,
            by = join_by(nombre_ies,
                         codigo_ies
            )) |> 
  filter(!is.na(comuna_sede)) |> 
  relocate(comuna_sede, .after = nombre_ies)

# dividir cantidades por sedes
datos3 <- datos2 |> 
  mutate(valor = round(valor, 1)) |>
  mutate(valor = valor/n_sedes)


# # revisar
# datos3 |> 
#   select(-starts_with("tipo_institucion")) |> 
#   filter(variable == "N° de académicos por insitución",
#          subvariable == "Total General") |>
#   print(n=30)
# 
# datos3 |>
#   select(-starts_with("tipo_institucion")) |>
#   filter(variable == "N° de JCE por Institución",
#          subvariable == "Total General") |>
#   print(n=30)


# calcular ----
# academicos_jce_comuna <- datos3 |> 
#   filter(tipo == "JCE",
#          variable == "N° de JCE por Institución",
#          subvariable == "Total General") |> 
#   group_by(region_sede, comuna_sede) |> 
#   summarize(docentes = sum(valor, na.rm = T))
#   
# academicos_comuna <- datos3 |> 
#   filter(tipo != "JCE",
#          variable == "N° de académicos por insitución",
#          subvariable == "Total General") |> 
#   group_by(region_sede, comuna_sede) |> 
#   summarize(docentes = sum(valor, na.rm = T))


datos4 <- datos3 |> 
  filter(variable %in% c("N° de JCE por Institución", "N° de académicos por insitución"),
         subvariable == "Total General") |> 
  group_by(region_sede, comuna_sede, variable) |> 
  summarize(docentes = sum(valor, na.rm = T)) |> 
  ungroup() |> 
  tidyr::pivot_wider(names_from = variable, values_from = docentes) |> 
  rename(academicos_jce = 3, academicos = 4)


datos4
