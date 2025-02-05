# Corresponde a las bases de datos de Oferta Académica, entre los años 2010 y 2024, elaboradas a partir de la información entregada por las propias instituciones de Educación Superior al Servicio de Información de Educación Superior (SIES), de Mineduc, en virtud de lo dispuesto en la Ley N° 20.129.
# 
# https://www.mifuturo.cl/bases-de-datos-de-oferta-academica/
#   
# https://www.mifuturo.cl/wp-content/uploads/2024/07/Oferta_Academica_2024_SIES_04_07_2024_WEB_EE.zip


# sedes de instituciones de educación superios (IES) con la comuna donde se ubican

library(readr)
library(dplyr)

# cargar sedes
sedes <- read_csv2("datos/datos_originales/Oferta_Academica_2024_SIES_04_07_2024_WEB_EE.csv",
                    locale = locale(encoding = "latin1")) |> 
  janitor::clean_names()

sedes |> glimpse()

# limpiar datos
sedes1 <- sedes |> 
  select(nombre_ies, codigo_ies, 
         codigo_sede, nombre_sede,
         region_sede, provincia_sede, comuna_sede) |> 
  distinct() |>
  add_count(nombre_ies, name = "n_sedes")



# cargar códigos únicos territoriales
cut_comunas <- read_csv2("datos/datos_externos/cut_comuna.csv") |> 
  select(-abreviatura_region, -contains("provincia")) |> 
  mutate(comuna = toupper(nombre_comuna),
         comuna = stringr::str_replace_all(comuna, 
                                           c("Á"="A", "É"="E", "Í"="I", "Ó"="O", "Ú"="U"))
  )

# agregar códigos únicos territoriales
sedes2 <- sedes1 |> 
  # corregir comunas
  mutate(comuna_sede = recode(comuna_sede,
                              "LA CALERA" = "CALERA")) |> 
  left_join(cut_comunas, 
            by = join_by(comuna_sede == comuna)) |> 
  select(-region_sede, -provincia_sede, -comuna_sede) |> 
  relocate(ends_with("region"), .after = nombre_sede) |> 
  relocate(ends_with("comuna"), .after = nombre_sede)


# guardar ----
readr::write_csv2(sedes2, "datos/mineduc_sedes_ed_superior_2024.csv")

