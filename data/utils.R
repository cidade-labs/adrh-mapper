setwd('/Users/ashaibani/Desktop/coruna_labs/adrh-mapper/data')

library(dplyr)
library(readr)

extract_cusec <- function(section_col) substr(section_col, 1, 10)

fix_spanish_number <- function(x) {
  x[x == "."] <- NA
  x <- gsub("\\.", "", x)
  x <- gsub(",", ".", x)
  as.numeric(x)
}

drop_rollup_rows <- function(df, cusec_col = "CUSEC") {
  df %>% filter(!is.na(.data[[cusec_col]]))
}

# filters: named list, e.g. list(Sexo = "Total", `Tramos de edad` = "Menos de 18 años")
clean_adrh_table <- function(filepath, filters = list(), year = 2023,
                             value_col = "Total", output_name) {
  raw <- read_tsv(filepath, show_col_types = FALSE, col_types = cols(Total = col_character()))
  df <- raw %>% filter(Municipios == "15030 Coruña, A", Periodo == year)
  
  for (col in names(filters)) {
    df <- df %>% filter(.data[[col]] == filters[[col]])
  }
  
  clean <- df %>%
    mutate(CUSEC = extract_cusec(Secciones),
           value = fix_spanish_number(.data[[value_col]])) %>%
    drop_rollup_rows("CUSEC") %>%
    select(CUSEC, value)
  
  write_csv(clean, paste0("clean/", output_name, "_cusec_2023.csv"))
  clean
}