source("src/etl/instruction_aggregate.R")

fixture <- tibble::tibble(
  event = c("Existing A", "Existing B"),
  date = as.POSIXct(c("2024-01-01", "2024-01-02"), tz = "UTC"),
  status = c("Graduate Student", "Staff"),
  department = c("Statistics", "Library"),
  institution = c("UCLA", "UCLA"),
  categories = c("R", "Python"),
  standardized_department = c("Statistics", "Library")
)

combined <- load_instruction_attendance(fixture)
aggregate <- dplyr::filter(combined, record_granularity == "aggregate")

stopifnot(nrow(aggregate) == 9L)
stopifnot(sum(aggregate$attendance_count) == 937L)
stopifnot(sum(combined$attendance_count) == 939L)
stopifnot(all(is.na(aggregate$institution)))
stopifnot(all(is.na(aggregate$department)))
stopifnot(all(is.na(aggregate$standardized_department)))
stopifnot(all(is.na(aggregate$school)))
stopifnot(all(is.na(aggregate$organizational_parent)))
stopifnot(sum(combined$attendance_count[combined$institution == "UCLA"], na.rm = TRUE) == 2L)
stopifnot(sum(combined$attendance_count[is.na(combined$institution)]) == 937L)
stopifnot(sum(combined$ucla_held) == 2L)
stopifnot(length(unique(aggregate$event_id)) == 9L)

message("Instruction aggregate tests passed.")

full_attendee_data <- load_instruction_attendee_data()
full_combined <- load_instruction_attendance(full_attendee_data)

stopifnot(nrow(full_attendee_data) == 14828L)
stopifnot(sum(full_combined$attendance_count) == 15765L)
stopifnot(sum(full_attendee_data$institution == "UCLA", na.rm = TRUE) == 1575L)
stopifnot(sum(full_combined$attendance_count[full_combined$ucla_held]) == 4350L)
stopifnot(sum(full_combined$attendance_count[full_combined$ucla_held & is.na(full_combined$institution)]) == 2775L)
stopifnot(!any(full_combined$ucla_held & !is.na(full_combined$institution) & full_combined$institution != "UCLA"))
stopifnot(!any(full_combined$ucla_held[full_combined$session_venue %in% c("mixed", "non_ucla") & is.na(full_combined$institution)]))
stopifnot(all(is.na(full_combined$organizational_parent[full_combined$ucla_held & is.na(full_combined$institution)])))
session_venue <- readr::read_tsv("data/reference/instruction/session_venue_2017_2020.tsv", show_col_types = FALSE)
stopifnot(nrow(session_venue) == 134L)
stopifnot(nrow(dplyr::anti_join(
  session_venue,
  dplyr::transmute(full_attendee_data, date = as.Date(date, tz = "UTC"), event),
  by = c("date", "event")
)) == 0L)
stopifnot(sum(full_combined$attendance_count[full_combined$record_granularity == "aggregate"]) == 937L)
stopifnot(sum(full_combined$attendance_count[full_combined$institution == "UCLA" & !is.na(full_combined$organizational_parent)], na.rm = TRUE) == 838L)
stopifnot(sum(full_combined$attendance_count[full_combined$institution == "UCLA" & !is.na(full_combined$standardized_department) & is.na(full_combined$organizational_parent)], na.rm = TRUE) == 29L)
stopifnot(all(is.na(full_combined$organizational_parent[full_combined$institution != "UCLA" & !is.na(full_combined$institution)])))

message("Full instruction source tests passed.")
