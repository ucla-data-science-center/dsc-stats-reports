# Registered seats by program and year (claim-register.md #12).
# Shared by instruction.qmd and capability.qmd so both pages draw the same figure.
# UCLA secondary tints plus a warm gray (brand.ucla.edu, verified 2026-09-26).
# Checked with the dataviz validator across all pairs: worst CVD separation
# deltaE 11.8, normal-vision 15.3 (floor 15). Darkest Gold and Lighter Blue sit
# under 3:1 against white, so white gaps and the program-by-year table are the relief.

seat_program_levels <- c("DSC workshops", "UC Carpentries (joint series)",
                         "Library Carpentry (UC, May 2026)", "Love Data Week", "GIS Week")
seat_program_colors <- setNames(c("#003B5C", "#FFB81C", "#8BB8E8", "#8C8279", "#2774AE"),
                                seat_program_levels)

seats_caption <- paste(
  "Registered seats, 2017-2026; 2026 partial. From 2020 through 2024 most instruction was",
  "online and open across UC campuses (UC Carpentries, Love Data Week, GIS Week), which is",
  "why seat counts rise sharply in those years. Registrations, not unique people or attendance."
)

read_seats <- function(path = "data/processed/canonical/instruction_seats_by_program_year.csv") {
  if (file.exists(path)) readr::read_csv(path, show_col_types = FALSE) else tibble::tibble()
}

seats_alt_text <- function(seats) {
  if (nrow(seats) == 0) return("Registered seats by program (data not loaded)")
  sy <- dplyr::arrange(dplyr::summarise(seats, n = sum(registered_seats), .by = year), year)
  sprintf(paste("Stacked bar chart of registered workshop seats by year and program, 2017 to 2026.",
                "Yearly totals: %s. Love Data Week and the UC Carpentries series account for most",
                "seats from 2021 on. The full values are in the table on the instruction page."),
          paste(sy$year, scales::comma(sy$n), sep = ": ", collapse = "; "))
}

seats_chart <- function(seats) {
  seats |>
    dplyr::mutate(program = factor(program, levels = rev(seat_program_levels))) |>
    ggplot2::ggplot(ggplot2::aes(x = factor(year), y = registered_seats, fill = program)) +
    ggplot2::geom_col(width = 0.72, color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_manual(values = seat_program_colors, breaks = seat_program_levels, name = NULL) +
    ggplot2::scale_y_continuous(labels = scales::comma, expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::labs(x = NULL, y = "Registered seats") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   legend.position = "bottom", legend.justification = "left") +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 2))
}
