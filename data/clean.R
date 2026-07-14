setwd('/Users/ashaibani/Desktop/coruna_labs/adrh-mapper/data')
source("utils.R")

d <- "20260714"  # update per your file dates

# 1-2: Income headline
clean_adrh_table(paste0("raw/ine_t30989_", d, ".csv"),
                 filters = list(`Indicadores de renta media y mediana` = "Renta neta media por persona"),
                 output_name = "income-mean-person")

clean_adrh_table(paste0("raw/ine_t30989_", d, ".csv"),
                 filters = list(`Indicadores de renta media y mediana` = "Renta neta media por hogar"),
                 output_name = "income-mean-household")

# 3: Fixed threshold, <7500€, sex=Total
clean_adrh_table(paste0("raw/ine_t30991_", d, ".csv"),
                 filters = list(Sexo = "Total",
                                `Distribución de la renta por unidad de consumo` = "Población con ingresos por unidad de consumo por debajo de 7.500 Euros"),
                 output_name = "poverty-fixed-7500eur")

# 4: Relative threshold, <60% median, sex=Total
clean_adrh_table(paste0("raw/ine_t30994_", d, ".csv"),
                 filters = list(Sexo = "Total",
                                `Distribución de la renta por unidad de consumo` = "Población con ingresos por unidad de consumo por debajo 60% de la mediana"),
                 output_name = "poverty-relative-below60pct")

# 5: Relative threshold, >200% median, sex=Total
clean_adrh_table(paste0("raw/ine_t30994_", d, ".csv"),
                 filters = list(Sexo = "Total",
                                `Distribución de la renta por unidad de consumo` = "Población con ingresos por unidad de consumo por encima 200% de la mediana"),
                 output_name = "affluence-relative-above200pct")

# 6: Relative threshold, <60% median, under 18, sex=Total
clean_adrh_table(paste0("raw/ine_t30995_", d, ".csv"),
                 filters = list(Sexo = "Total",
                                `Tramos de edad` = "Menos de 18 años",
                                `Distribución de la renta por unidad de consumo` = "Población con ingresos por unidad de consumo por debajo 60% de la mediana"),
                 output_name = "child-poverty-relative-below60pct")

# 7-8: Demographic percentages
clean_adrh_table(paste0("raw/ine_t30997_", d, ".csv"),
                 filters = list(`Indicadores demográficos` = "Porcentaje de población menor de 18 años"),
                 output_name = "pct-under18")

clean_adrh_table(paste0("raw/ine_t30997_", d, ".csv"),
                 filters = list(`Indicadores demográficos` = "Porcentaje de población de 65 y más años"),
                 output_name = "pct-over65")

# 9: Gini
clean_adrh_table(paste0("raw/ine_t37694_", d, ".csv"),
                 filters = list(`Índice de Gini y Distribución de la renta P80/P20` = "Índice de Gini"),
                 output_name = "gini-index")

# 10-14: Income source composition
income_sources <- c(
  "salario" = "income-source-salary",
  "pensiones" = "income-source-pensions",
  "prestaciones por desempleo" = "income-source-unemployment",
  "otras prestaciones" = "income-source-other-benefits",
  "otros ingresos" = "income-source-other-income"
)

for (src in names(income_sources)) {
  clean_adrh_table(paste0("raw/ine_t30990_", d, ".csv"),
                   filters = list(`Distribución por fuente de ingresos` = paste0("Fuente de ingreso: ", src)),
                   output_name = income_sources[[src]])
}

# 15: P80/P20
clean_adrh_table(paste0("raw/ine_t37694_", d, ".csv"),
                 filters = list(`Índice de Gini y Distribución de la renta P80/P20` = "Distribución de la renta P80/P20"),
                 output_name = "p80p20-ratio")
