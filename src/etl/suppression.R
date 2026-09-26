# Small-cell suppression for public breakdowns (metrics-governance.md).
#
# Units with a count under the threshold are folded into a single "other"
# row, so no small cell is shown on its own. If that combined row is itself
# under the threshold it is dropped too. The number of folded units is kept
# as an attribute so captions can say what was suppressed.

suppress_small_cells <- function(df, label_col, n_col, threshold = 5L,
                                 other_label = "Other units (each fewer than 5)") {
  small <- df[[n_col]] < threshold
  kept <- df[!small, , drop = FALSE]
  other_n <- sum(df[[n_col]][small])
  if (any(small) && other_n >= threshold) {
    other <- tibble::as_tibble(setNames(list(other_label, other_n), c(label_col, n_col)))
    kept <- dplyr::bind_rows(kept, other)
  }
  attr(kept, "suppressed_units") <- sum(small)
  kept
}

suppression_note <- function(df, unit = "units") {
  n <- attr(df, "suppressed_units")
  if (is.null(n) || n == 0) return("")
  sprintf(" %d %s with fewer than 5 are combined into one row, or omitted if that row is also under 5.", n, unit)
}
