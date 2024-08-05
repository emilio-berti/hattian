#' Yeakel et al. (?) model.
#'
#' @importFrom rstan sampling
#' @export
#' @param fw Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @param m_prey Numeric vector of the prey body mass.
#' @param m_pred Numeric vector of the predator body mass.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
#' @examples
#' \dontrun{
#' library(hattian)
#' fw <- matrix(sample(c(0, 1), 100, replace = TRUE), nrow = 10, ncol = 10)
#' m_prey <- runif(10, 0, 1)
#' m_pred <- runif(10, 0, 1)
#' fit <- yeakel_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
#' }
yeakel_stan <- function(fw, m_prey, m_pred, ...) {
  stopifnot(is(fw, "matrix"))
  stopifnot(is(m_prey, "numeric"))
  stopifnot(is(m_pred, "numeric"))
  m_prey <- matrix(m_prey, nrow = nrow(fw), ncol = ncol(fw))
  m_pred <- matrix(m_prey, nrow = nrow(fw), ncol = ncol(fw), byrow = TRUE)
  basals <- which(colSums(fw) == 0)
  fw <- fw[, -basals]
  m_prey <- m_prey[, -basals]
  m_pred <- m_pred[, -basals]
  standata <- list(
    N = length(fw),
    link = as.vector(fw),
    mr = log10(as.vector(m_prey / m_pred))
  )
  out <- sampling(stanmodels$yeakel, data = standata, ...)
  return (out)
}

#' Predict Using Yeakel Model
#'
#' @importFrom rstan extract
#' @export
#' @param fit Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @param m_prey Numeric vector of the prey body mass.
#' @param m_pred Numeric vector of the predator body mass.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
#' @examples
#' \dontrun{
#' library(hattian)
#' fw <- matrix(sample(c(0, 1), 100, replace = TRUE), nrow = 10, ncol = 10)
#' m_prey <- runif(10, 0, 1)
#' m_pred <- runif(10, 0, 1)
#' fit <- yeakel_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
#' }
yeakel_predict <- function(
  fit,
  m_prey,
  m_pred,
  samples = 300
) {
  stopifnot(is(fit), "stanfit")
  stopifnot(is(m_prey, "numeric"))
  stopifnot(is(m_pred, "numeric"))
  stopifnot(is(samples), "numeric")
  logit <- function(x) 1 / (1 + exp(-x))
  m_prey <- matrix(m_prey, nrow = nrow(fw), ncol = ncol(fw))
  m_pred <- matrix(m_prey, nrow = nrow(fw), ncol = ncol(fw), byrow = TRUE)
  posterior <- rstan::extract(fit, c("a1", "a2", "a3"))
  posterior <- do.call(cbind, posterior)
  posterior <- posterior[sample(seq_len(nrow(posterior)), samples), ]
  posterior <- as.data.frame(posterior)
  p <- array(NA, dim = c(nrow(m_prey), ncol(m_pred), samples))
  for (i in seq_len(samples)) {
    p[, , i] <- with(posterior[i, ], a1 + a2 * m_prey / m_pred + a3 * (m_prey / m_pred) ^ 2)
  }
  p <- logit(p)
  p_mean <- apply(p, MARGIN = c(1, 2), mean)
  p_sd <- apply(p, MARGIN = c(1, 2), sd)
  return (list(mean = p_mean, sd = p_sd))
}
