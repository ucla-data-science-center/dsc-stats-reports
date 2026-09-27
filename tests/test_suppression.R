# Small-cell suppression: nothing under 5 is shown on its own.
source("src/etl/suppression.R")

df <- tibble::tibble(unit = c("A", "B", "C", "D"), n = c(40L, 6L, 3L, 4L))
out <- suppress_small_cells(df, "unit", "n")
stopifnot(identical(out$unit, c("A", "B", "Other units (each fewer than 5)")))
stopifnot(identical(as.integer(out$n), c(40L, 6L, 7L)))
stopifnot(attr(out, "suppressed_units") == 2L)

# A combined row under the threshold is dropped as well.
out2 <- suppress_small_cells(df[c(1, 3), ], "unit", "n")
stopifnot(identical(out2$unit, "A"))
stopifnot(all(out2$n >= 5))

# Nothing to suppress: data unchanged, note empty.
out3 <- suppress_small_cells(df[1:2, ], "unit", "n")
stopifnot(nrow(out3) == 2L, suppression_note(out3) == "")

message("Suppression tests passed.")
