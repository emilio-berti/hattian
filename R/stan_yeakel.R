#' @title Yeakel et al. (2014) model.
#'
#' @importFrom rstan sampling
#' @export
#' @param fw Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @param masses Numeric vector of the species' body mass.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
#' @examples
#' \dontrun{
#' library(hattian)
#' fw <- matrix(sample(c(0, 1), 100, replace = TRUE), nrow = 10, ncol = 10)
#' masses <- runif(10, 0, 1)
#' fit <- yeakel_stan(fw, masses, warmup = 100, iter = 200)
#' }
yeakel_stan <- function(fw, masses, ...) {
  stopifnot(is(fw, "matrix"))
  stopifnot(is(masses, "numeric"))
  m_prey <- matrix(masses, nrow = nrow(fw), ncol = ncol(fw))
  m_pred <- matrix(masses, nrow = nrow(fw), ncol = ncol(fw), byrow = TRUE)
  basals <- which(colSums(fw) == 0)
  if (length(basals) > 0) {
    m_prey <- m_prey[, -basals]
    m_pred <- m_pred[, -basals]
    fw <- fw[, -basals]
  }
  standata <- list(
    N = length(fw),
    link = as.vector(fw),
    mr = log10(as.vector(m_pred / m_prey))
  )
  out <- sampling(stanmodels$yeakel, data = standata, ...)
  return (out)
}

#' Predict Using Yeakel Model
#'
#' @importFrom rstan extract
#' @importFrom stats sd
#' @export
#' @param fit Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @param m_prey Numeric vector of the prey body mass.
#' @param m_pred Numeric vector of the predator body mass.
#' @param samples Numeric value of the number of samples to draw.
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
  m_prey <- matrix(m_prey, nrow = length(m_prey), ncol = length(m_pred))
  m_pred <- matrix(m_prey, nrow = length(m_prey), ncol = length(m_pred), byrow = TRUE)
  posterior <- rstan::extract(fit, c("a1", "a2", "a3"))
  posterior <- do.call(cbind, posterior)
  posterior <- posterior[sample(seq_len(nrow(posterior)), samples), ]
  posterior <- as.data.frame(posterior)
  p <- array(NA, dim = c(nrow(m_prey), ncol(m_pred), samples))
  for (i in seq_len(samples)) {
    p[, , i] <- with(posterior[i, ], a1 + a2 * log10(m_pred / m_prey) + a3 * log10(m_pred / m_prey) ^ 2)
  }
  p <- logit(p)
  p_mean <- apply(p, MARGIN = c(1, 2), mean)
  p_sd <- apply(p, MARGIN = c(1, 2), sd)
  return (list(mean = p_mean, sd = p_sd))
}
