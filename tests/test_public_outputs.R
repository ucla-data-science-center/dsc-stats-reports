# Public research outputs: every row must be verified and have publication permission.
x <- readr::read_csv("data/processed/canonical/research_outputs_public.csv", show_col_types = FALSE)
bad <- x[x$verification_status != "verified" | x$public_permission != "yes", ]
if (nrow(bad) > 0) stop("Unverified or unpermitted rows in research_outputs_public.csv: ", paste(bad$output, collapse = "; "))
message("Public outputs gate passed (", nrow(x), " verified rows).")
