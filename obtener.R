# https://www.mifuturo.cl/bases-de-datos-personal-academico/
# Bases de datos de Personal Académico, entre los años 2008 y 2024

library(rvest)
library(dplyr)
library(stringr)

# obtener datos desde el sitio web
sitio <- session("https://www.mifuturo.cl/bases-de-datos-personal-academico/") |> 
  read_html()

elementos <- sitio |> 
  html_elements(".col-content") |> 
  html_elements("a")

texto <- elementos |> html_text()
enlace <- elementos |> html_attr("href")

tabla_enlaces <- tibble(texto, enlace)

# extraer enlace correcto
archivo <- tabla_enlaces |>
  filter(str_detect(texto, "2024")) |> 
  filter(!str_detect(texto, "Hist")) |> 
  pull(enlace)

# definir ruta donde guardar el archivo
dir.create("datos")
dir.create("datos/datos_originales")

ruta <- paste0("datos/datos_originales/", str_extract(archivo, "PAC.*xls"))

# descargar
download.file(archivo,
              ruta)


# # obtener glosario
# download.file("https://www.mifuturo.cl/wp-content/uploads/2024/07/OFICIAL_GLOSARIO_MATRICULA_WEB_E.pdf",
#               "datos/datos_originales/glosario.pdf")
# No disponible
