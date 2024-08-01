test_that("confusion matrix works", {
  x <- matrix(rbinom(100, 1, .3), nrow = 10, ncol = 10)
  y <- matrix(runif(100, 0, 1), nrow = 10, ncol = 10)
  th <- runif(1)
  tp <- sum(x & y >= th)
  tn <- sum(!x & y < th)
  fn <- sum(x & y < th)
  fp <- sum(!x & y >= th)
  conf_mat <- confusion(x, y, th)
  expect_equal(
    conf_mat,
    matrix(c(tp, fn, fp, tn), nrow = 2, byrow = TRUE),
    ignore_attr = TRUE
  )
})
