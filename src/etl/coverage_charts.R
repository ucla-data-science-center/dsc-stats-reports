# Coverage by unit and topic trends, from suppressed aggregates only.
# Sources: data/processed/coverage/ (see README there). Blanks and "<5" stay blank:
# never impute, never subtract, never sum across units or tags.

coverage_dir <- "data/processed/coverage"

zone_levels <- c("North campus: humanities and social sciences",
                 "Northeast campus: professional schools",
                 "Central campus: education, information, psychology",
                 "South campus: sciences and engineering",
                 "Health sciences",
                 "Not placed in a zone")

read_coverage <- function() {
  u <- readr::read_csv(file.path(coverage_dir, "unit_summary_2026-11-22.csv"),
                       show_col_types = FALSE)
  z <- readr::read_csv(file.path(coverage_dir, "unit_zones.csv"), show_col_types = FALSE)
  dplyr::left_join(u, z, by = "unit_key") |>
    dplyr::mutate(zone = factor(zone, levels = zone_levels)) |>
    dplyr::arrange(zone, dplyr::desc(users))
}

read_topics <- function() {
  readr::read_csv(file.path(coverage_dir, "topic_by_year_suppressed_2026-11-22.csv"),
                  col_types = "cic") |>
    dplyr::mutate(n = suppressWarnings(as.integer(tagged_appointments)))
}

# Users per unit (a floor), one panel per campus zone. "Other or unmapped" is left out
# of the chart (it is not a unit) and stays in the table.
coverage_chart <- function(cov) {
  d <- cov |>
    dplyr::filter(unit_key != "other", !is.na(zone), zone != "Not placed in a zone") |>
    dplyr::mutate(unit_label = forcats::fct_reorder(unit_label, users),
                  zone = forcats::fct_relabel(zone, \(x) stringr::str_wrap(x, 28)))
  ggplot2::ggplot(d, ggplot2::aes(x = users, y = unit_label)) +
    ggplot2::geom_col(fill = "#2774AE", width = 0.7) +
    ggplot2::geom_text(ggplot2::aes(label = users), hjust = -0.2, size = 3.3, color = "#1a1a1a") +
    ggplot2::facet_wrap(~zone, scales = "free_y", ncol = 2) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.15))) +
    ggplot2::labs(x = "Users with any recorded DSC use (a floor)", y = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   strip.text = ggplot2::element_text(face = "bold", hjust = 0))
}

coverage_alt <- function(cov) {
  d <- cov |> dplyr::filter(unit_key != "other", !is.na(zone), zone != "Not placed in a zone") |>
    dplyr::arrange(dplyr::desc(users)) |> dplyr::slice_head(n = 5)
  sprintf(paste("Horizontal bar charts of users per campus unit, grouped by five campus zones.",
                "The five largest units are %s. Every unit's value is in the table below."),
          paste0(d$unit_label, " (", d$users, ")", collapse = ", "))
}

# Top topics by tagged appointments per year. Ranking uses the visible cells only;
# no totals are printed because an appointment can carry several tags.
# Years run earliest at the top. "<5" cells get a text mark, not a bar.
topic_labels <- c(gis = "GIS", python = "Python", spreadsheets_cleaning = "Spreadsheets and cleaning",
                  r = "R", statistics = "Statistics", repository_sharing = "Repository and sharing",
                  data_finding = "Data finding", data_management = "Data management",
                  visualization = "Visualization", web_scraping = "Web scraping")

topic_top <- function(tp, k = 6) {
  tp |> dplyr::summarise(s = sum(n, na.rm = TRUE), .by = tag) |>
    dplyr::slice_max(s, n = k, with_ties = FALSE) |> dplyr::pull(tag)
}

topic_chart <- function(tp, k = 6) {
  keep <- topic_top(tp, k)
  d <- tp |> dplyr::filter(tag %in% keep, year >= 2019, year <= 2025) |>
    dplyr::mutate(tag = factor(dplyr::coalesce(topic_labels[tag], tag),
                               levels = dplyr::coalesce(topic_labels[keep], keep)),
                  year = factor(year, levels = rev(sort(unique(year)))))
  ggplot2::ggplot(d, ggplot2::aes(x = dplyr::coalesce(n, 0L), y = year)) +
    ggplot2::geom_col(fill = "#2774AE", width = 0.7) +
    ggplot2::geom_text(ggplot2::aes(label = ifelse(is.na(n), "<5", n)),
                       hjust = -0.25, size = 3, color = "#1a1a1a") +
    ggplot2::facet_wrap(~tag, ncol = 3) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.2))) +
    ggplot2::labs(x = "Tagged appointments (estimates)", y = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   strip.text = ggplot2::element_text(face = "bold", hjust = 0))
}

topic_alt <- function(tp, k = 6) {
  keep <- topic_top(tp, k)
  sprintf(paste("Small-multiple horizontal bar charts of tagged consultation appointments per year,",
                "2019 to 2025, for the %d most-tagged topics: %s. Years run from earliest at the top.",
                "Cells under 5 are marked <5. Tags are estimates."),
          length(keep), paste(dplyr::coalesce(topic_labels[keep], keep), collapse = ", "))
}
