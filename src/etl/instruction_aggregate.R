library(dplyr)
library(readr)

load_instruction_attendance <- function(
    attendee_data,
    aggregate_path = "data/raw/instruction/workshop_attendance_aggregate.csv") {
  attendee_records <- attendee_data |>
    mutate(
      attendance_count = 1L,
      counting_unit = "attendee_event",
      attendance_rule = "libinsight_attendee_record",
      school = NA_character_,
      source_system = "LibInsight",
      source_period = NA_character_,
      record_granularity = "attendee"
    )

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
