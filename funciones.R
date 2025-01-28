extraer_subtabla <- function(data, columnas = 7:9, fila = 2, tipo = "Total") {
  data <- datos_academicos_num

  # seleccionar las columnas de cada variable
  data_subset <- data |> 
    select(1:2, all_of(columnas))
  
  # extraer el título de la variable
  titulo <- data_subset |> select(3) |> names()
  
  # poner nombres de columnas
  data_subset |> 
    row_to_names(fila) |> 
    rename(año = 1, id = 2) |>
    # pivotar
    pivot_longer(cols = 3:last_col(),
                 names_to = "variable", values_to = "valor") |> 
    # limpiar números
    mutate(valor = parse_number(valor, locale = locale(decimal_mark = ",", grouping_mark = "."))) |> 
    # poner metadatos
    mutate(tipo = tipo,
           variable = titulo)
}
