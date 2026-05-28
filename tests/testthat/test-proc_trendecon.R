test_that("a failing index does not abort the others, successes are copied", {
  tmp <- withr::local_tempdir()
  withr::local_options(path_trendecon = tmp)

  # pretend the per-keyword pipeline already wrote these seasonally adjusted
  # files; proc_trendecon() copies them to data/ch once the index succeeds
  dir.create(file.path(tmp, "raw", "ch"), recursive = TRUE)
  for (nm in c("good1", "good2")) {
    writeLines(
      c("time,value", "2020-01-01,1"),
      file.path(tmp, "raw", "ch", paste0(nm, "_sa.csv"))
    )
  }

  local_mocked_bindings(
    proc_index = function(keywords, geo, index_name, backfill_from = NULL) {
      if (index_name == "bad") stop("boom")
      invisible(TRUE)
    },
    .package = "trendecon"
  )

  status <- proc_trendecon("CH", list(good1 = "kw", bad = "kw", good2 = "kw"))

  expect_equal(status$index, c("good1", "bad", "good2"))
  expect_equal(status$ok, c(TRUE, FALSE, TRUE))
  expect_true(file.exists(file.path(tmp, "data", "ch", "good1_sa.csv")))
  expect_true(file.exists(file.path(tmp, "data", "ch", "good2_sa.csv")))
  expect_false(file.exists(file.path(tmp, "data", "ch", "bad_sa.csv")))
})

test_that("proc_trendecon errors only when every index fails", {
  tmp <- withr::local_tempdir()
  withr::local_options(path_trendecon = tmp)

  local_mocked_bindings(
    proc_index = function(keywords, geo, index_name, backfill_from = NULL) {
      stop("boom")
    },
    .package = "trendecon"
  )

  expect_error(
    proc_trendecon("CH", list(a = "kw", b = "kw")),
    "All indices failed"
  )
})
