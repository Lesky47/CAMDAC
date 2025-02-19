test_that("rrbs tumor_normal_pipeline", {
  # Log test run
  logger::log_info("Running test: rrbs tumor_normal_pipeline. Estimated time: 25 minutes.")

  # Ensure pipeline files are downloaded
  pf_dir <- "pf_rrbs"
  if (!fs::dir_exists(pf_dir)) {
    pf <- download_pipeline_files("rrbs", directory = pf_dir)
  }

  # Setup inputs
  patient_id <- "PRRBS"
  tumor_id <- "T"
  normal_id <- "N"
  tumor_bam <- system.file("extdata", "test_tumor.bam", package = "CAMDAC")
  normal_bam <- system.file("extdata", "test_normal.bam", package = "CAMDAC")
  sex <- "XY"
  path <- fs::path_abs("results/")
  pipeline_files <- fs::path_abs(pf_dir)
  build <- "hg38"

  # Call pipeline
  pipeline_tumor_normal(
    patient_id, tumor_id, normal_id, tumor_bam, normal_bam, sex, path,
    pipeline_files, build,
    min_tumor = 1, min_normal = 1,
    n_cores = 10, mq = 0
  )

  # Check output directories are created and have more than one file each
  expected_outdirs <- sapply(
    c("Allelecounts", "Copy_number", "Methylation"),
    function(x) fs::path(path, patient_id, x)
  )
  outdirs_exist <- all(sapply(expected_outdirs, fs::dir_exists))
  expect_true(outdirs_exist)

  contained_files <- sapply(expected_outdirs, function(x) length(fs::dir_ls(x)))
  outfiles_written <- all(contained_files > 1)
  expect_true(outfiles_written)

  log_info("Test complete. Result written to: {path}")
})
