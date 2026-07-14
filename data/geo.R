library(sf); library(dplyr); library(readr); library(purrr)

# --- 1. Pull A Coruña sections directly from INE (server-side filtered) ---
base <- "https://www.ine.es/geoserver/ogc/features/v1/collections/WMS_INE_SECCIONES_G01:Secciones_2023/items"
q <- paste0(base, "?f=application/json&limit=1000",
            "&filter=", URLencode("CUMUN='15030'"), "&filter-lang=cql-text")

geo <- st_read(q) %>%
  st_transform(4326) %>%
  mutate(CUSEC = as.character(CUSEC)) %>%
  select(CUSEC)

# --- 2. Load and merge the 15 clean indicator tables ---
files <- c(
  income_mean_household             = "clean/income-mean-household_cusec_2023.csv",
  income_mean_person                = "clean/income-mean-person_cusec_2023.csv",
  poverty_fixed_7500eur             = "clean/poverty-fixed-7500eur_cusec_2023.csv",
  poverty_relative_below60pct       = "clean/poverty-relative-below60pct_cusec_2023.csv",
  affluence_relative_above200pct    = "clean/affluence-relative-above200pct_cusec_2023.csv",
  child_poverty_relative_below60pct = "clean/child-poverty-relative-below60pct_cusec_2023.csv",
  gini_index                        = "clean/gini-index_cusec_2023.csv",
  p80p20_ratio                      = "clean/p80p20-ratio_cusec_2023.csv",
  pct_under18                       = "clean/pct-under18_cusec_2023.csv",
  pct_over65                        = "clean/pct-over65_cusec_2023.csv",
  income_source_salary              = "clean/income-source-salary_cusec_2023.csv",
  income_source_pensions            = "clean/income-source-pensions_cusec_2023.csv",
  income_source_unemployment        = "clean/income-source-unemployment_cusec_2023.csv",
  income_source_other_benefits      = "clean/income-source-other-benefits_cusec_2023.csv",
  income_source_other_income        = "clean/income-source-other-income_cusec_2023.csv"
)

tabs   <- imap(files, ~ read_csv(.x, col_types = cols(CUSEC = "c")) %>% rename(!!.y := value))
joined <- reduce(tabs, full_join, by = "CUSEC")

# --- 3. Join data onto geometry, write GeoJSON ---
out <- geo %>% left_join(joined, by = "CUSEC")

# sanity checks before writing
cat("Geometry sections:", nrow(geo), "\n")
cat("Sections with no income match:", sum(is.na(out$income_mean_household)), "\n")

dir.create("data", showWarnings = FALSE)
st_write(out, "geo/adrh_cusec_2023.geojson", delete_dsn = TRUE)