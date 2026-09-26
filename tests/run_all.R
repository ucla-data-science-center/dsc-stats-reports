# Runs every test file in its own R process; any failure stops the build.
for (t in sort(list.files("tests", pattern = "^test_.*\\.R$", full.names = TRUE))) {
  status <- system2("Rscript", t)
  if (status != 0) stop("Test failed: ", t)
}
