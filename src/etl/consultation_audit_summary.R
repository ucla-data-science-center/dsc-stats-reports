library(readr)
library(dplyr)
library(janitor)
library(lubridate)
library(tidyr)
library(purrr)

audit_start_ts <- as.POSIXct("2023-01-01 00:00:00", tz = "UTC")
audit_end_ts <- as.POSIXct("2025-12-31 23:59:59", tz = "UTC")

dsc_members <- c(
  "Jamie Jamison", "Tim Dennis", "Doug Daniels", "Ali, Ibraheem",
  "Leigh Phan", "Zhiyuan Yao", "Gillian Bailey", "Kristian Allen",
  "Zhiyuan (Jee-Wan) Yao"
)

datasquad_members <- c(
  "JULIA WOOD", "KEONA MAE PABLO", "WILLIAM FOOTE", "deleted",
  "EMILY GONG", "Vincenty Front", "Shail Mirpuri", "Tristan Dewing",
  "Vince Front", "Lawrence Lee", "Hyerin Lee", "LORETTA HU",
  "LUKAS HAGER", "AIMEE XU", "Aditya Bharath"
)

trello_filter_path <- "data/reference/consultations/trello_task_filters.csv"
trello_default_excluded_lists <- c("Team Info", "Inbox", "Future Projects/Ideas")

normalize_person_name <- function(x) {
  x <- as.character(x)
  x <- ifelse(is.na(x), NA_character_, stringr::str_squish(x))
  has_comma <- !is.na(x) & grepl(",", x, fixed = TRUE)
  x[has_comma] <- vapply(strsplit(x[has_comma], ",", fixed = TRUE), function(parts) {
    parts <- trimws(parts)
    if (length(parts) >= 2) paste(parts[2], parts[1]) else parts[1]
  }, character(1))
  stringr::str_to_lower(stringr::str_squish(x))
}

parse_trello_activity_ts <- function(x) {
  if (inherits(x, "POSIXt")) {
    return(as.POSIXct(x, tz = "UTC"))
  }
  parse_date_time(
    as.character(x),
    orders = c("ymd HMSOSz", "ymd HMSz", "ymd HMSOS", "ymd HMS", "ymd HMOSz", "ymd HMOS"),
    tz = "UTC"
  )
}

read_libinsights_csv <- function(path, source_detail = "primary") {
  x <- read_csv(path, show_col_types = FALSE) %>% clean_names()

  dt_col <- case_when(
    "start_date_time" %in% names(x) ~ "start_date_time",
    "event_date_and_time" %in% names(x) ~ "event_date_and_time",
    TRUE ~ NA_character_
  )

  if (is.na(dt_col)) {
    stop(paste("No supported datetime column found in", path))
  }

  user_col <- case_when(
    "user_name" %in% names(x) ~ "user_name",
    "entered_by" %in% names(x) ~ "entered_by",
    TRUE ~ NA_character_
  )

  # Support both Calendly event exports and LibInsight detailed logging exports.
  x %>%
    mutate(
      source_file = basename(path),
      start_date_time = parse_date_time(
        .data[[dt_col]],
        orders = c("ymd HMS", "ymd HM", "mdy HMS", "mdy HM", "mdy IMp", "ymd IMS p"),
        tz = "UTC"
      ),
      source = "libinsights",
      source_detail = source_detail,
      source_record_kind = if_else("event_uuid" %in% names(.), "scheduled_export", "manual_detail_log"),
      subtype = if_else(source_record_kind == "scheduled_export", "scheduled_consult", "manual_consult_log"),
      user_name = if (!is.na(user_col)) as.character(.data[[user_col]]) else NA_character_,
      user_name_norm = normalize_person_name(user_name),
      canceled = if ("canceled" %in% names(.)) as.character(canceled) else NA_character_,
      canceled_flag = tolower(coalesce(canceled, "false")) %in% c("true", "t", "1"),
      group = case_when(
        user_name %in% dsc_members ~ "DSC",
        user_name %in% datasquad_members ~ "Datasquad",
        TRUE ~ "Other"
      )
    ) %>%
    transmute(
      event_uuid = if ("event_uuid" %in% names(.)) as.character(event_uuid) else NA_character_,
      start_date_time,
      user_name = as.character(user_name),
      group,
      source,
      source_detail,
      source_record_kind,
      subtype,
      canceled,
      canceled_flag,
      user_name_norm,
      source_file
    )
}

lib_primary <- read_libinsights_csv(
  "data/raw/consultations/libinsights-full21-24-dataframe.csv",
  "primary"
)

lib_backfill_paths <- list.files(
  "data/raw/consultations/imported_gdrive/libinsights",
  pattern = "\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

local_calendly_backfill_paths <- list.files(
  "data/raw/consultations",
  pattern = "^(event-data-from-.*|filtered-event-data-from-.*)\\.csv$",
  recursive = FALSE,
  full.names = TRUE
)

all_lib_backfill_paths <- unique(c(lib_backfill_paths, local_calendly_backfill_paths))

lib_backfill <- if (length(all_lib_backfill_paths) > 0) {
  map_dfr(all_lib_backfill_paths, ~{
    detail <- if (grepl("imported_gdrive", .x, fixed = TRUE)) "gdrive_backfill" else "local_backfill"
    read_libinsights_csv(.x, detail)
  })
} else {
  tibble()
}

primary_event_ids <- lib_primary %>%
  filter(!is.na(event_uuid), event_uuid != "") %>%
  pull(event_uuid) %>%
  unique()

lib_backfill_new <- lib_backfill %>%
  filter(is.na(event_uuid) | event_uuid == "" | !(event_uuid %in% primary_event_ids))

lib_all <- bind_rows(lib_primary, lib_backfill_new) %>%
  mutate(start_minute = floor_date(start_date_time, unit = "minute"))

scheduled_keys <- lib_all %>%
  filter(source_record_kind == "scheduled_export", !is.na(start_minute), !is.na(user_name_norm), user_name_norm != "") %>%
  transmute(key = paste(start_minute, user_name_norm))

lib <- lib_all %>%
  mutate(
    heuristic_duplicate_manual_vs_scheduled = source_record_kind == "manual_detail_log" &
      !is.na(start_minute) & !is.na(user_name_norm) & user_name_norm != "" &
      paste(start_minute, user_name_norm) %in% scheduled_keys$key
  ) %>%
  select(
    start_date_time, user_name, group, source, source_detail, source_record_kind, subtype,
    canceled, canceled_flag, heuristic_duplicate_manual_vs_scheduled
  )

signin <- read_csv(
  "data/raw/consultations/datasquad-sign-in.csv",
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(
    start_date_time = mdy_hms(timestamp, tz = "UTC"),
    user_name = "DataSquad Walk-in",
    group = "Datasquad",
    source = "datasquad_signin",
    subtype = "walkin_consult"
  ) %>%
  transmute(start_date_time, user_name, group, source, subtype)

trello <- read_csv(
  "data/raw/consultations/ucla-datasquad-projects-trello.csv",
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(
    comment_count = suppressWarnings(as.integer(comment_count)),
    comment_count = if_else(is.na(comment_count) | comment_count < 0, 0L, comment_count),
    archived_flag = tolower(as.character(archived)) %in% c("true", "t", "1"),
    task_activity_ts = suppressWarnings(parse_trello_activity_ts(last_activity_date))
  ) %>%
  {
    if (file.exists(trello_filter_path)) {
      filter_map <- read_csv(trello_filter_path, show_col_types = FALSE) %>%
        clean_names() %>%
        filter(source == "trello", coalesce(include_in_report, FALSE) == FALSE) %>%
        mutate(list_name = as.character(list_name))
      left_join(., filter_map %>% select(list_name, exclude_reason), by = "list_name")
    } else {
      mutate(., exclude_reason = if_else(list_name %in% trello_default_excluded_lists, "default_excluded_list", NA_character_))
    }
  } %>%
  mutate(
    task_reportable = is.na(exclude_reason)
  )

trello_all <- trello %>%
  uncount(comment_count, .remove = FALSE, .id = "instance") %>%
  mutate(
    start_date_time = task_activity_ts,
    user_name = members,
    group = "Datasquad",
    source = "trello",
    subtype = "trello_task_comment_weighted"
  ) %>%
  transmute(start_date_time, user_name, group, source, subtype)

trello_reportable <- trello %>%
  filter(task_reportable) %>%
  uncount(comment_count, .remove = FALSE, .id = "instance") %>%
  mutate(
    start_date_time = task_activity_ts,
    user_name = members,
    group = "Datasquad",
    source = "trello_reportable",
    subtype = "trello_task_comment_weighted_filtered"
  ) %>%
  transmute(start_date_time, user_name, group, source, subtype)

all_rows <- bind_rows(lib, signin, trello_all)

coverage <- all_rows %>%
  group_by(source, subtype) %>%
  summarise(
    rows = n(),
    min_date = min(start_date_time, na.rm = TRUE),
    max_date = max(start_date_time, na.rm = TRUE),
    .groups = "drop"
  )

window <- all_rows %>%
  filter(
    !is.na(start_date_time),
    start_date_time >= audit_start_ts,
    start_date_time <= audit_end_ts
  ) %>%
  mutate(year = year(start_date_time))

direct_rows <- bind_rows(
  lib %>%
    filter(
      # exclude canceled scheduled exports from direct consultation counts
      !(source_record_kind == "scheduled_export" & canceled_flag),
      # combine manual + scheduled, but remove likely duplicate manual logs when a scheduled export exists
      !heuristic_duplicate_manual_vs_scheduled
    ) %>%
    transmute(start_date_time, user_name, group, source = "libinsights_direct_deduped", canceled_flag),
  signin %>% transmute(start_date_time, user_name, group, source, canceled_flag = FALSE)
) %>%
  filter(start_date_time >= audit_start_ts, start_date_time <= audit_end_ts) %>%
  mutate(year = year(start_date_time))

trello_reportable_window <- trello_reportable %>%
  filter(
    !is.na(start_date_time),
    start_date_time >= audit_start_ts,
    start_date_time <= audit_end_ts
  ) %>%
  mutate(year = year(start_date_time))

trello_cards_window <- trello %>%
  filter(!is.na(task_activity_ts), task_activity_ts >= audit_start_ts, task_activity_ts <= audit_end_ts) %>%
  mutate(year = year(task_activity_ts))

trello_reportable_cards_window <- trello %>%
  filter(task_reportable, !is.na(task_activity_ts), task_activity_ts >= audit_start_ts, task_activity_ts <= audit_end_ts) %>%
  mutate(year = year(task_activity_ts))

summary_totals <- tibble(
  metric = c(
    "DSC consultations (scheduled via LibInsights)",
    "Direct consultations (DSC + DataSquad, combined LibInsight + sign-in; canceled excluded; manual logs deduped where possible)",
    "DataSquad direct consultations (LibInsights + sign-in)",
    "DataSquad Trello task cards (all)",
    "DataSquad Trello task cards (reportable; excludes backlog/admin lists)",
    "DataSquad Trello task rows (comment-weighted)",
    "DataSquad Trello reportable task rows (comment-weighted; excludes backlog/admin lists)",
    "Datasquad total incl. Trello",
    "Datasquad total incl. reportable Trello tasks",
    "Combined DSC + Datasquad direct consultations only",
    "Other/uncategorized LibInsights rows",
    "LibInsight manual logs flagged as likely duplicates of scheduled exports (heuristic)",
    "LibInsights rows in 2025 (all statuses)",
    "LibInsights rows in 2025 (not canceled)"
  ),
  value = c(
    nrow(filter(window, group == "DSC", source == "libinsights")),
    nrow(direct_rows),
    nrow(filter(window, group == "Datasquad", source %in% c("libinsights", "datasquad_signin"))),
    nrow(trello_cards_window),
    nrow(trello_reportable_cards_window),
    nrow(filter(window, source == "trello")),
    nrow(trello_reportable_window),
    nrow(filter(window, group == "Datasquad")),
    nrow(filter(window, group == "Datasquad", source != "trello")) + nrow(trello_reportable_window),
    nrow(filter(window, group %in% c("DSC", "Datasquad"), source != "trello")),
    nrow(filter(window, group == "Other", source == "libinsights")),
    nrow(filter(lib, heuristic_duplicate_manual_vs_scheduled, start_date_time >= audit_start_ts, start_date_time <= audit_end_ts)),
    nrow(filter(window, source == "libinsights", year == 2025)),
    nrow(filter(window, source == "libinsights", year == 2025, !(tolower(coalesce(canceled, "false")) %in% c("true", "t", "1"))))
  )
)

summary_totals_tagged <- summary_totals %>%
  mutate(
    metric_id = c(
      "dsc_direct_consults_libinsights_count",
      "direct_consults_combined_deduped_count",
      "datasquad_direct_consults_count",
      "datasquad_trello_task_cards_all_count",
      "datasquad_trello_task_cards_reportable_count",
      "datasquad_trello_task_activity_comment_weighted_all_count",
      "datasquad_trello_task_activity_comment_weighted_reportable_count",
      "datasquad_total_with_trello_all_count",
      "datasquad_total_with_trello_reportable_count",
      "direct_consults_dsc_plus_datasquad_count",
      "libinsights_other_uncategorized_rows_count",
      "libinsight_manual_logs_heuristic_duplicate_count",
      "libinsights_2025_rows_all_status_count",
      "libinsights_2025_rows_not_canceled_count"
    ),
    metric_family = c(
      "direct_consultations",
      "direct_consultations",
      "direct_consultations",
      "task_count",
      "task_count",
      "task_activity",
      "task_activity",
      "composite_workload",
      "composite_workload",
      "direct_consultations",
      "data_quality",
      "data_quality",
      "coverage_check",
      "coverage_check"
    ),
    unit_type = c(
      "consultation_rows",
      "consultation_rows",
      "consultation_rows",
      "task_cards",
      "task_cards",
      "comment_weighted_task_activity_rows",
      "comment_weighted_task_activity_rows",
      "mixed_rows",
      "mixed_rows",
      "consultation_rows",
      "libinsights_rows",
      "libinsights_rows",
      "libinsights_rows",
      "libinsights_rows"
    ),
    source_scope = c(
      "libinsights",
      "libinsights+datasquad_signin_deduped",
      "libinsights+datasquad_signin",
      "trello",
      "trello_filtered",
      "trello",
      "trello_filtered",
      "datasquad_direct+trello",
      "datasquad_direct+trello_filtered",
      "direct_consult_sources_only",
      "libinsights",
      "libinsights_combined",
      "libinsights",
      "libinsights"
    ),
    reporting_use = c(
      "reportable",
      "reportable",
      "reportable",
      "context",
      "reportable",
      "context",
      "reportable",
      "context",
      "reportable",
      "reportable",
      "audit",
      "audit",
      "audit",
      "audit"
    )
  ) %>%
  select(metric_id, metric, value, metric_family, unit_type, source_scope, reporting_use)

by_year_group <- window %>%
  count(year, group, name = "n") %>%
  arrange(year, group)

by_year_source <- window %>%
  count(year, source, name = "n") %>%
  arrange(year, source)

by_year_task_mode <- bind_rows(
  window %>% filter(source == "trello") %>% mutate(task_metric = "trello_all_comment_weighted"),
  trello_reportable_window %>% mutate(task_metric = "trello_reportable_comment_weighted"),
  trello_cards_window %>% mutate(task_metric = "trello_all_task_cards"),
  trello_reportable_cards_window %>% mutate(task_metric = "trello_reportable_task_cards")
) %>%
  count(year, task_metric, name = "n") %>%
  arrange(year, task_metric)

trello_filter_audit <- trello %>%
  count(list_name, archived_flag, task_reportable, name = "cards") %>%
  arrange(desc(cards))

write_csv(coverage, "data/processed/consultations/consultation_audit_source_coverage.csv")
write_csv(summary_totals, "data/processed/consultations/consultation_audit_2023_2025_summary.csv")
write_csv(summary_totals_tagged, "data/processed/consultations/consultation_audit_2023_2025_summary_tagged.csv")
write_csv(by_year_group, "data/processed/consultations/consultation_audit_2023_2025_by_year_group.csv")
write_csv(by_year_source, "data/processed/consultations/consultation_audit_2023_2025_by_year_source.csv")
write_csv(by_year_task_mode, "data/processed/consultations/consultation_audit_2023_2025_by_year_task_mode.csv")
write_csv(trello_filter_audit, "data/processed/consultations/trello_filter_audit_cards.csv")

print(coverage)
print(summary_totals)
print(by_year_group)
print(by_year_source)
print(by_year_task_mode)
