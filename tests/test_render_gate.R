# Render gate (design brief item 14). Fails the build when:
#  1. a headline figure lacks a window, a unit, or a claim-register entry;
#  2. a page cites a headline figure that is not in the canonical file;
#  3. a department / affiliation / organizational-parent breakdown is built
#     without small-cell suppression (threshold 5).

headline <- readr::read_csv("data/processed/canonical/headline_aggregates.csv", show_col_types = FALSE)
register <- paste(readLines("claim-register.md", warn = FALSE), collapse = "\n")
fail <- character()

for (i in seq_len(nrow(headline))) {
  h <- headline[i, ]
  if (is.na(h$period_start) || is.na(h$period_end)) fail <- c(fail, paste0(h$metric_id, ": missing window"))
  if (is.na(h$unit) || h$unit == "") fail <- c(fail, paste0(h$metric_id, ": missing unit"))
  if (!grepl(paste0("`", h$metric_id, "`"), register, fixed = TRUE)) {
    fail <- c(fail, paste0(h$metric_id, ": no claim-register entry names it"))
  }
}

# Only pages in the site render list are published.
quarto_cfg <- readLines("_quarto.yml", warn = FALSE)
pages <- sub("^\\s*-\\s*([A-Za-z0-9_-]+\\.qmd).*$", "\\1",
             grep("^\\s*-\\s*[A-Za-z0-9_-]+\\.qmd\\s*(#.*)?$", quarto_cfg, value = TRUE))
for (p in pages) {
  src <- paste(readLines(p, warn = FALSE), collapse = "\n")
  used <- regmatches(src, gregexpr('hl\\("([a-z_]+)"\\)', src))[[1]]
  used <- unique(sub('hl\\("([a-z_]+)"\\)', "\\1", used))
  missing <- setdiff(used, headline$metric_id)
  if (length(missing)) fail <- c(fail, paste0(p, ": cites unknown figure(s) ", paste(missing, collapse = ", ")))

  chunks <- regmatches(src, gregexpr("```\\{r[^}]*\\}.*?```", src))[[1]]
  for (ch in chunks) {
    breakdown <- grepl("(\\.by = (standardized_department|status|organizational_parent|c\\(organizational_parent)|count\\((department|ucla_affiliation))", ch)
    visible <- grepl("datatable|ggplot|kable|plot_ly", ch)
    guarded <- grepl("suppress_small_cells|filter\\(n >= 5\\)", ch)
    if (breakdown && visible && !guarded) {
      fail <- c(fail, paste0(p, ": breakdown chunk without suppression: ", substr(ch, 1, 60)))
    }
  }
}

if (length(fail)) stop("Render gate failed:\n- ", paste(fail, collapse = "\n- "))
message("Render gate passed (", nrow(headline), " headline figures, ", length(pages), " pages).")
