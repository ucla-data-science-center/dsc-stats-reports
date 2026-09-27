# Public aggregates from the consultation records file.
#
# The row-level file (data/processed/consultations/dsc_consult_merged.rds) holds
# free-text fields that can contain personal contact details, so it is not
# tracked in the public repository. Run this script locally, where the file
# exists, to refresh the aggregate CSVs that consulting.qmd publishes.
# Small-cell suppression (threshold 5) is applied here, before anything is
# written, so no public file ever contains a cell under 5.
#
#   Rscript src/etl/consult_public_aggregates.R

suppressPackageStartupMessages({ library(dplyr); library(readr); library(lubridate) })
source("src/etl/suppression.R")

src <- "data/processed/consultations/dsc_consult_merged.rds"
out <- "data/processed/consultations/public"
if (!file.exists(src)) stop("Row-level consultation file not found locally: ", src)
dir.create(out, showWarnings = FALSE, recursive = TRUE)

consult <- readRDS(src) |>
  mutate(ucla_affiliation = case_when(
    ucla_affiliation %in% c("Graduate", "Graduate Student", "Visiting Graduate Student") ~ "Graduate Student",
    ucla_affiliation %in% c("Undergrauate 3rd & Undergraduate", "Undergraduate") ~ "Undergraduate",
    TRUE ~ ucla_affiliation
  ))

by_year <- consult |> filter(!is.na(start_date_time)) |>
  count(year = year(start_date_time), name = "records")

by_department <- consult |>
  filter(!is.na(department), !department %in% c("DSC", "Library", "UCLA")) |>
  count(department, sort = TRUE, name = "records") |>
  suppress_small_cells("department", "records", other_label = "Other departments (each fewer than 5)")

by_affiliation <- consult |> filter(!is.na(ucla_affiliation)) |>
  count(ucla_affiliation, sort = TRUE, name = "records") |>
  suppress_small_cells("ucla_affiliation", "records", other_label = "Other affiliations (each fewer than 5)")

by_team <- consult |> filter(!is.na(group)) |> count(group, name = "records")

window <- consult |> filter(!is.na(start_date_time)) |>
  summarise(first_date = as.Date(min(start_date_time)), last_date = as.Date(max(start_date_time)),
            suppressed_departments = attr(by_department, "suppressed_units"),
            suppressed_affiliations = attr(by_affiliation, "suppressed_units"))

stopifnot(all(by_department$records >= 5), all(by_affiliation$records >= 5))
write_csv(by_year, file.path(out, "consult_records_by_year.csv"))
write_csv(by_department, file.path(out, "consult_records_by_department.csv"))
write_csv(by_affiliation, file.path(out, "consult_records_by_affiliation.csv"))
write_csv(by_team, file.path(out, "consult_records_by_team.csv"))
write_csv(window, file.path(out, "consult_records_window.csv"))
message("Wrote public consultation aggregates to ", out)
