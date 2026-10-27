test_that("bcall_auto() reproduces the README results", {
  res <- bcall_auto(readme_rollcall(), pivot = "Leg_B", verbose = FALSE)$results
  expect_equal(res$d1, c(-0.74352102, 1.36481227, -0.07685435, -0.06203237, -0.72360680),
               tolerance = 1e-7)
  expect_equal(res$d2, c(0.2785371, 0.3977486, 0.9476066, 0.3582163, 0.3908790),
               tolerance = 1e-6)
  expect_equal(res$auto_cluster, c("left", "right", "left", "left", "left"))
})

test_that("the pivot's side of d1 is positive, whatever the row order", {
  rc <- two_blocs()
  a <- bcall_auto(rc, pivot = "r_1", verbose = FALSE)$results
  b <- bcall_auto(rc[rev(rownames(rc)), ], pivot = "r_1", verbose = FALSE)$results
  expect_gt(mean(a[grepl("^r_", a$legislator), "d1"]), 0)
  expect_equal(a[rownames(rc), "d1"], b[rownames(rc), "d1"])
  expect_true(all(a[grepl("^r_", a$legislator), "auto_cluster"] == "right"))
})

test_that("without a pivot bcall_auto() warns that the sign is arbitrary", {
  rc <- two_blocs()
  expect_warning(a <- bcall_auto(rc, verbose = FALSE), "sign of d1 is arbitrary")
  expect_warning(b <- bcall_auto(rc[rev(rownames(rc)), ], verbose = FALSE), "arbitrary")
  expect_lt(mean(a$results[grepl("^r_", a$results$legislator), "d1"]), 0)
  expect_gt(mean(b$results[grepl("^r_", b$results$legislator), "d1"]), 0)
})

test_that("bcall() accepts any two labels and orients d1 with the pivot", {
  rc <- two_blocs()
  cl <- data.frame(cluster = ifelse(grepl("^r_", rownames(rc)), "gov", "opp"),
                   row.names = rownames(rc))
  res <- bcall(rc, cl, pivot = "r_2", verbose = FALSE)$results
  expect_gt(mean(res[res$cluster == "gov", "d1"]), 0)
  expect_lt(mean(res[res$cluster == "opp", "d1"]), 0)

  named <- stats::setNames(cl$cluster, rownames(cl))
  expect_equal(bcall(rc, named, pivot = "r_2", verbose = FALSE)$results$d1, res$d1)
})

test_that("unanimous votes do not change the scores", {
  rc <- two_blocs()
  cl <- data.frame(cluster = ifelse(grepl("^r_", rownames(rc)), "a", "b"), row.names = rownames(rc))
  with_unanimous <- cbind(rc, unanimous = 1)
  expect_equal(bcall(with_unanimous, cl, pivot = "r_1", verbose = FALSE)$results$d1,
               bcall(rc, cl, pivot = "r_1", verbose = FALSE)$results$d1)
})

test_that("the participation threshold drops legislators", {
  rc <- two_blocs()
  rc["l_1", 1:36] <- NA
  cl <- data.frame(cluster = ifelse(grepl("^r_", rownames(rc)), "a", "b"), row.names = rownames(rc))
  res <- bcall(rc, cl, pivot = "r_1", threshold = 0.2, verbose = FALSE)
  expect_false("l_1" %in% res$results$legislator)
  expect_equal(res$metadata$n_legislators_analyzed, nrow(rc) - 1)
})

test_that("a single vote works and gives no d2", {
  rc <- data.frame(v1 = c(1, -1, 1, -1), row.names = paste0("L", 1:4))
  cl <- data.frame(cluster = c("a", "b", "a", "b"), row.names = paste0("L", 1:4))
  res <- bcall(rc, cl, pivot = "L2", verbose = FALSE)$results
  expect_equal(nrow(res), 4)
  expect_true(all(is.na(res$d2)))
})

test_that("bad input gives clear errors", {
  rc <- readme_rollcall()
  cl <- data.frame(cluster = c("a", "b", "a", "a", "a"), row.names = rownames(rc))
  bad <- rc
  bad[1, 1] <- 2
  expect_error(bcall_auto(bad, pivot = "Leg_B", verbose = FALSE), "Invalid vote values")
  expect_error(bcall_auto(rc, threshold = 2, verbose = FALSE), "between 0 and 1")
  expect_error(bcall_auto(as.matrix(rc), verbose = FALSE), "must be a data.frame")
  expect_error(bcall(rc, cl, verbose = FALSE), "pivot must be specified")
  expect_error(bcall(rc, cl, pivot = "Nobody", verbose = FALSE), "not found")
  three <- data.frame(cluster = c("a", "b", "c", "a", "b"), row.names = rownames(rc))
  expect_error(bcall(rc, three, pivot = "Leg_B", verbose = FALSE), "exactly 2 unique values")
})

test_that("results print briefly and messages can be silenced", {
  expect_silent(res <- suppressMessages(bcall_auto(readme_rollcall(), pivot = "Leg_B")))
  expect_s3_class(res, "bcall_result")
  expect_output(print(res), "Pivot: Leg_B")
  expect_message(bcall_auto(readme_rollcall(), pivot = "Leg_B"), "legislators analyzed")
})

test_that("the plots build", {
  res <- bcall_auto(readme_rollcall(), pivot = "Leg_B", verbose = FALSE)
  expect_s3_class(plot_bcall_analysis(res), "ggplot")
  expect_s3_class(plot_bcall_analysis(res, show_names = TRUE), "ggplot")
  expect_error(plot_bcall_analysis(list(a = 1)), "Input must be results")
  skip_if_not_installed("plotly")
  expect_s3_class(plot_bcall_analysis_interactive(res), "plotly")
})
