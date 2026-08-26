source("src/etl/instruction_aggregate.R")

data <- load_instruction_attendee_data() |>
  dplyr::mutate(
    year = lubridate::year(date),
    series = dplyr::case_when(
      stringr::str_detect(stringr::str_to_lower(dplyr::coalesce(event, "")), "love data|ldw") ~ "Love Data Week",
      stringr::str_detect(stringr::str_to_lower(dplyr::coalesce(event, "")), "gis week|uc gis") ~ "GIS Week",
      TRUE ~ NA_character_
    )
  )

actual <- data |>
  dplyr::filter(!is.na(series)) |>
  dplyr::count(series, year)

expected <- tibble::tribble(
  ~series, ~year, ~n,
  "GIS Week", 2020, 883L,
  "GIS Week", 2021, 892L,
  "GIS Week", 2022, 596L,
  "GIS Week", 2023, 370L,
  "Love Data Week", 2019, 5L,
  "Love Data Week", 2022, 2585L,
  "Love Data Week", 2023, 2182L,
  "Love Data Week", 2024, 2413L
)

stopifnot(identical(dplyr::arrange(actual, series, year), dplyr::arrange(expected, series, year)))
stopifnot(sum(actual$n[actual$series == "GIS Week"]) == 2741L)
stopifnot(sum(actual$n[actual$series == "Love Data Week"]) == 7185L)

message("Instruction series coverage tests passed.")
