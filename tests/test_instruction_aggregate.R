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
stopifnot(sum(combined$attendance_count[combined$institution == "UCLA"], na.rm = TRUE) == 2L)
stopifnot(sum(combined$attendance_count[is.na(combined$institution)]) == 937L)
stopifnot(length(unique(aggregate$event_id)) == 9L)

message("Instruction aggregate tests passed.")
