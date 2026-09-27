# Privacy gate: the public repository must not track row-level consultation or
# registration data, and tracked text data must not contain email addresses or
# phone numbers. Runs in CI before render (pixi run check).

tracked <- system2("git", c("ls-files"), stdout = TRUE)
fail <- character()

blocked <- grepl("^data/raw/consultations/|^data/processed/consultations/[^/]+\\.(rds|rda)$|^archive/data_legacy_link/|^archive/dsc-stats-eval/data/", tracked)
if (any(blocked)) fail <- c(fail, paste("row-level data tracked:", tracked[blocked]))

email <- "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.(edu|com|org|net|gov|io)\\b"
phone <- "\\(?\\b[0-9]{3}\\)?[-. ][0-9]{3}[-. ][0-9]{4}\\b"
data_files <- tracked[grepl("^data/.*\\.(csv|tsv|json|txt)$", tracked)]
for (f in data_files) {
  txt <- readLines(f, warn = FALSE, encoding = "UTF-8")
  if (any(grepl(email, txt, perl = TRUE))) fail <- c(fail, paste("email-like string in", f))
  if (any(grepl(phone, txt, perl = TRUE))) fail <- c(fail, paste("phone-like string in", f))
}

if (length(fail)) stop("Privacy gate failed:\n- ", paste(fail, collapse = "\n- "))
message("Privacy gate passed (", length(data_files), " tracked data files scanned).")
