extraer_subtabla <- function(data, columnas = 7:9, 
                             fila = 2, # fila con etiquetas de variables
                             segunda_fila = FALSE, # true si la variable no viene en la columna, sino en la fila de abajo (por ejemplo, en "Rango de edad" (13:18), la variable es "N° JCE por rango edad mujer"
                             tipo = "Total") {
  # data <- datos_academicos_num
  # browser()
  
  # seleccionar las columnas de cada variable
  data_subset <- data |> 
    select(1:3, all_of(columnas))
  
  # extraer el título de la variable
  if (segunda_fila) {
    titulo <- data_subset |> select(4) |> slice(1) |> pull(1)
  } else {
    titulo <- data_subset |> select(4) |> names()
  }
  
  if (str_detect(titulo, "\\.\\.\\.")) {
    titulo <- data_subset |> select(4) |> slice(1) |> pull(1)
  }
  
  # poner nombres de columnas
  data_subset |> 
    row_to_names(fila) |> 
    rename(año = 1, codigo_ies = 2, nombre_ies = 3) |>
    # pivotar
    pivot_longer(cols = 4:last_col(),
                 names_to = "subvariable", values_to = "valor") |> 
    # limpiar números
    mutate(valor = parse_number(valor, locale = locale(decimal_mark = ".", grouping_mark = ""))) |> 
    # poner metadatos
    mutate(tipo = tipo,
           variable = titulo) |> 
    relocate(variable, .before = "subvariable")
}
