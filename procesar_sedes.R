# Corresponde a las bases de datos de Oferta Académica, entre los años 2010 y 2024, elaboradas a partir de la información entregada por las propias instituciones de Educación Superior al Servicio de Información de Educación Superior (SIES), de Mineduc, en virtud de lo dispuesto en la Ley N° 20.129.
# 
# https://www.mifuturo.cl/bases-de-datos-de-oferta-academica/
#   
# https://www.mifuturo.cl/wp-content/uploads/2024/07/Oferta_Academica_2024_SIES_04_07_2024_WEB_EE.zip


# sedes de instituciones de educación superios (IES) con la comuna donde se ubican

library(readr)
library(dplyr)

oferta <- read_csv2("datos/datos_originales/Oferta_Academica_2024_SIES_04_07_2024_WEB_EE.csv",
                    locale = locale(encoding = "latin1")) |> 
  janitor::clean_names()

oferta |> glimpse()

sedes <- oferta |> 
  select(nombre_ies, codigo_ies, 
         codigo_sede, nombre_sede,
         region_sede, provincia_sede, comuna_sede) |> 
  distinct() |>
  add_count(nombre_ies, name = "n_sedes")

sedes |> 
  print(n=30)


# guardar ----
readr::write_csv2(sedes, "datos/sedes_ed_superior_2024.csv")

