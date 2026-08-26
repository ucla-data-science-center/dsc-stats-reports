library(dplyr)
library(readr)
library(stringr)

load_instruction_attendee_data <- function(
    raw_path = "data/raw/instruction/dsc_workshops.csv") {
  source("src/etl/standardize_map.R", local = TRUE)

  standardize_department <- function(value) {
    if (is.na(value) || str_trim(value) == "") {
      return(NA_character_)
    }
    mapped <- standardize_map[[str_to_lower(str_trim(value))]]
    if (is.null(mapped) || mapped %in% c("NA", "NEED TO LOOKUP")) {
      return(NA_character_)
    }
    mapped
  }

  read_csv(
    raw_path,
    na = c("", "NA", "N/A"),
    show_col_types = FALSE,
    col_types = cols(
      event = col_character(),
      date = col_datetime(),
      status = col_character(),
      department = col_character(),
      institution = col_character(),
      categories = col_character()
    )
  ) |>
    mutate(
      status = str_replace_all(
        status,
        regex("graduate student|grad student|grad\\. student", ignore_case = TRUE),
        "Graduate Student"
      ),
      standardized_department = vapply(
        department,
        standardize_department,
        character(1)
      )
    )
}

load_instruction_attendance <- function(
    attendee_data,
    aggregate_path = "data/raw/instruction/workshop_attendance_aggregate.csv",
    organizational_parent_path = "data/reference/instruction/department_to_organizational_parent_v2.tsv") {
  attendee_records <- attendee_data |>
    mutate(
      attendance_count = 1L,
      counting_unit = "attendee_event",
      attendance_rule = "consolidated_attendee_record",
      school = NA_character_,
      source_system = "Consolidated instruction",
      source_period = NA_character_,
      record_granularity = "attendee"
    )

  if (file.exists(organizational_parent_path)) {
    organizational_parent_map <- read_tsv(
      organizational_parent_path,
      show_col_types = FALSE,
      na = c("", "NA", "N/A"),
      col_types = cols(.default = col_character())
    )
    if (anyDuplicated(str_to_lower(str_squish(organizational_parent_map$standardized_department)))) {
      stop("Organizational-parent crosswalk departments must be unique.")
    }
    attendee_records <- attendee_records |>
      mutate(organizational_parent_key = str_to_lower(str_squish(standardized_department))) |>
      left_join(
        organizational_parent_map |>
          filter(mapping_status == "active") |>
          transmute(
            organizational_parent_key = str_to_lower(str_squish(standardized_department)),
            organizational_parent,
            parent_type
          ),
        by = "organizational_parent_key"
      ) |>
      mutate(
        organizational_parent = if_else(institution == "UCLA", organizational_parent, NA_character_),
        parent_type = if_else(institution == "UCLA", parent_type, NA_character_)
      ) |>
      select(-organizational_parent_key)
  } else {
    attendee_records <- attendee_records |>
      mutate(organizational_parent = NA_character_, parent_type = NA_character_)
  }

  if (!file.exists(aggregate_path)) {
    return(attendee_records)
  }

  aggregate_records <- read_csv(
    aggregate_path,
    na = c("", "NA", "N/A"),
    show_col_types = FALSE,
    col_types = cols(
      event_id = col_character(),
      event = col_character(),
      date = col_date(),
      attendance_count = col_integer(),
      counting_unit = col_character(),
      attendance_rule = col_character(),
      institution = col_character(),
      department = col_character(),
      school = col_character(),
      categories = col_character(),
      source_system = col_character(),
      source_period = col_character()
    )
  ) |>
    mutate(
      status = NA_character_,
      standardized_department = NA_character_,
      organizational_parent = NA_character_,
      parent_type = NA_character_,
      record_granularity = "aggregate"
    )

  if (any(is.na(aggregate_records$attendance_count)) ||
      any(aggregate_records$attendance_count <= 0)) {
    stop("Aggregate workshop attendance_count values must be positive integers.")
  }
  if (anyDuplicated(aggregate_records$event_id)) {
    stop("Aggregate workshop event_id values must be unique.")
  }

  bind_rows(attendee_records, aggregate_records)
}
