library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(janitor)
library(readr)

source("funciones.R")

# obtener ruta del archivo
# (porque como el nombre de archivo tiene fecha, puede que el nombre cambie)
ruta_archivo <- list.files("datos/datos_originales", full.names = T) |> 
  str_subset("PAC.*xls") |> 
  str_subset("~", negate = TRUE)

.año <- str_extract(ruta_archivo, "\\d{4}")

# cargar datos ----
datos_academicos_num <- read_xlsx(ruta_archivo, sheet = 1) |> 
  rename(año = 1, codigo_ies = 2)

# jce = jornada completa equivalente
datos_academicos_jce <- read_xlsx(ruta_archivo, sheet = 2) |> 
  rename(año = 1)

# instituciones
instituciones <- datos_academicos_num |>
  select(1:6) |>
  filter(!is.na(año)) |> 
  clean_names() |> 
  select(-1) |> 
  distinct() |> 
  rename(codigo_ies = 1, nombre_ies = 2)


# datos_academicos_num |> 
#   behead("up", "a")
# 
# library(tidyxl)
# library(unpivotr)
# 
# # leer archivo excel como celdas
# celdas <- xlsx_cells(ruta_archivo, sheets = 1) |> 
#   select(row, col, data_type, numeric, character, date)
# 
# celdas |> 
#   filter(col %in% c(2, 7, 8, 9)) |> 
#   behead("left", "id") |> 
#   behead("up-left", "variable") |> 
#   behead("up", "b") |>
#   behead("up", "genero") |> 
#   select(id, genero, valor = numeric) |> 
#   pivot_wider(names_from = genero, values_from = valor)


# extraer tablas ----
# se extraen de esta forma porque en una sola hoja vienen multiples 
# variables con título en una fila, y niveles en otra fila

tablas <- list()

# N° de académicos por insitución		
tablas[[1]] <- datos_academicos_num |> 
  extraer_subtabla(7:9)

# Promedio de edad de los acádemicos		
tablas[[2]] <- datos_academicos_num |> 
  extraer_subtabla(10:12)

# N° acádemicos por rango de edad - Mujeres					
tablas[[3]] <- datos_academicos_num |> 
  extraer_subtabla(13:18, segunda_fila = T)

# N° académicos por rango de edad - Hombres					
tablas[[4]] <- datos_academicos_num |> 
  extraer_subtabla(19:24, segunda_fila = T)

# Número de JCE de la institución que trabajan en 1 o más instituciones		
tablas[[5]] <- datos_academicos_num |> 
  extraer_subtabla(25:27)

# N° de académicos por nivel de formación									
tablas[[6]] <- datos_academicos_num |> 
  extraer_subtabla(28:37)

# N° de académicos por región en que se desempeña (orden geográfico)																
tablas[[7]] <- datos_academicos_num |> 
  extraer_subtabla(38:54)

# N° de académicos por nacionalidad	
tablas[[8]] <- datos_academicos_num |> 
  extraer_subtabla(55:56)

# Promedio de horas acádemicas contratadas a la semana por académico		
tablas[[9]] <- datos_academicos_num |> 
  extraer_subtabla(57:59)

# N° de académicos por rango de horas contratadas				
tablas[[10]] <- datos_academicos_num |> 
  extraer_subtabla(60:64)


# jce ----

# N° de académicos por insitución		
tablas[[11]] <- datos_academicos_jce |> 
  extraer_subtabla(7:9, tipo = "JCE")

# Promedio de edad de los acádemicos		
tablas[[12]] <- datos_academicos_jce |> 
  extraer_subtabla(10:12, tipo = "JCE")

# N° acádemicos por rango de edad - Mujeres					
tablas[[13]] <- datos_academicos_jce |> 
    extraer_subtabla(13:18, segunda_fila = T, tipo = "JCE")

# N° académicos por rango de edad - Hombres					
tablas[[14]] <- datos_academicos_jce |> 
  extraer_subtabla(19:24, segunda_fila = T, tipo = "JCE")

# Número de JCE de la institución que trabajan en 1 o más instituciones		
tablas[[15]] <- datos_academicos_jce |> 
  extraer_subtabla(25:27, tipo = "JCE")

# N° de académicos por nivel de formación									
tablas[[16]] <- datos_academicos_jce |> 
  extraer_subtabla(28:37, tipo = "JCE")

# N° de académicos por región en que se desempeña (orden geográfico)																
tablas[[17]] <- datos_academicos_jce |> 
  extraer_subtabla(38:54, tipo = "JCE")

# N° de académicos por nacionalidad	
tablas[[18]] <- datos_academicos_jce |> 
  extraer_subtabla(55:56, tipo = "JCE")

# N° de académicos por rango de horas contratadas				
tablas[[19]] <- datos_academicos_jce |> 
  extraer_subtabla(57:60, tipo = "JCE")

# unir tablas
tablas_unidas <- tablas |> 
  bind_rows()

# revisar variables
tablas_unidas |> 
  distinct(tipo, variable)

# agregar nombres de universidades
personal_academico <- instituciones |> 
  left_join(tablas_unidas,
            by = join_by(codigo_ies, nombre_ies)) |> 
  relocate(tipo, .before = 1) |> 
  mutate(año = as.numeric(.año))


# guardar ----
readr::write_csv2(personal_academico, "datos/mineduc_personal_academico_2008-2024.csv")
writexl::write_xlsx(personal_academico, "datos/mineduc_personal_academico_2008-2024.xlsx")  
