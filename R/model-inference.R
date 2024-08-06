#' Compare Inference Models
#'
#' @importFrom loo loo loo_compare
#' @importFrom graphics abline
#'
#' @export
#' @param models List of models to compare. Better if it's a named list.
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
#' @examples
#' \dontrun{
#' library(hattian)
#' fw <- matrix(sample(c(0, 1), 100, replace = TRUE), nrow = 10, ncol = 10)
#' m_prey <- matrix(runif(10, 0, 1), nrow = 10, ncol = 10)
#' m_pred <- matrix(runif(10, 0, 1), nrow = 10, ncol = 10, byrow = TRUE)
#' fit1 <- yeakel_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
#' fit2 <- li_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
#' models <- list(yeakel = fit1, li = fit2)
#' compare_models(models)
#' }
#' 
compare_models <- function(models) {
	loo <- lapply(models, loo)
	comparison <- loo_compare(loo)
	return (comparison)
}

#' Confusion Matrix
#'
#' @export
#' @param fw Adjacency matrix of the food-web.
#' @param preds Numeric matrix with probabilistic prediction from an inference model.
#' @param th Numeric value of the threshold to apply.
#' @return The confusion matrix.
#'
confusion <- function(fw, preds, th) {
  preds[preds < th] <- 0
  preds[preds >= th] <- 1
  tp <- sum(fw == 1 & preds == 1)
  tn <- sum(fw == 0 & preds == 0)
  fp <- sum(fw == 0 & preds == 1)
  fn <- sum(fw == 1 & preds == 0)
  conf_mat <- matrix(
    c(tp, fn, fp, tn),
    byrow = TRUE,
    nrow = 2, ncol = 2,
    dimnames = list(c("obs.true", "obs.false"), c("pred.true", "pred.false"))
  )
  return (conf_mat)
}

#' Find Optimal Threshold
#'
#' @export
#' @param fw Adjacency matrix of the food-web.
#' @param preds Numeric matrix with probabilistic prediction from an inference model.
#' @param steps Numeric value of the steps of threshold test.
#' @return A list with the best threshold, sensitivity, specificity, and TSS statistics.
#'
#' @details
#' The optimal threshold is the one that maximizes the sum of specificity and sensitivity.
#'
find_threshold <- function(fw, preds, steps = 100) {
  roc <- as.data.frame(matrix(
    NA, nrow = steps, ncol = 3,
    dimnames = list(NULL, c("threshold", "sens", "spec"))
  ))
  roc[["threshold"]] <- seq(0, 1, length.out = steps)
  for (th in roc[["threshold"]]) {
    conf_mat <- confusion(fw, preds, th)
    roc[roc[["threshold"]] == th, c("sens", "spec")] <- c(
      conf_mat[1, 1] / rowSums(conf_mat)[1],
      conf_mat[2, 2] / rowSums(conf_mat)[2]
    )
  }
  with(roc, plot(1 - spec, sens, pch = 20, type = "b"))
  abline(0, 1, lty = 2, col = "grey70")
  best <- roc[with(roc, which.max(spec + sens)), ]
  best[["tss"]] <- with(best, sens + spec - 1)
  best <- as.list(best)
  return (best)
}
