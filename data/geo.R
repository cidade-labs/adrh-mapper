library(sf); library(dplyr); library(readr); library(purrr)

# --- 1. Pull A Coruña sections directly from INE (server-side filtered) ---
base <- "https://www.ine.es/geoserver/ogc/features/v1/collections/WMS_INE_SECCIONES_G01:Secciones_2023/items"
q <- paste0(base, "?f=application/json&limit=1000",
            "&filter=", URLencode("CUMUN='15030'"), "&filter-lang=cql-text")

geo_raw <- st_read(q) %>%
  st_transform(4326) %>%
  mutate(CUSEC = as.character(CUSEC)) %>%
  select(CUSEC)

# INE answers a municipality filter with the census sections *and* the district
# roll-up polygons that contain them — CUSEC ending in "000". Those ten have no
# indicator values of their own, so left in they sit on top of the real sections
# and paint a third of the municipality no-data grey. This is the geometry-side
# equivalent of utils.R::drop_rollup_rows.
geo <- geo_raw %>% filter(substr(CUSEC, 8, 10) != "000")

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
cat("Polygons returned by INE:", nrow(geo_raw), "\n")
cat("District roll-ups dropped:", nrow(geo_raw) - nrow(geo), "\n")
cat("Geometry sections:", nrow(geo), "\n")
cat("Sections with no income match:", sum(is.na(out$income_mean_household)), "\n")
stopifnot(nrow(out) == nrow(geo), !any(grepl("000$", out$CUSEC)))

st_write(out, "adrh_cusec_2023.geojson", delete_dsn = TRUE)