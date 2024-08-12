#' Li et al. (2024) model.
#'
#' @importFrom rstan extract
#' @importFrom stats sd
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
#' m_prey <- log10(seq(1.1, 1e2, length.out = 10))
#' m_pred <- log10(seq(1.1, 1e2, length.out = 10))
#' mus <- seq(0.5, 1.5, length.out = 10)
#' sigmas <- seq_len(10) / 1e2
#' thetas <- sqrt(seq_len(10) / 10)
#' p <- matrix(NA, nrow = 10, ncol = 10)
#' for (i in seq_along(m_pred)) {
#'   p[, i] <- thetas[i] * exp( -(m_pred[i] / m_prey - mus[i])^2 / (2 * sigmas[i]^2))
#' }
#' fw <- matrix(rbinom(10^2, 1, p), nrow = 10, ncol = 10, byrow = TRUE)
#' image(fw)
#' fit <- li_stan(fw, m_prey, m_pred, warmup = 100, iter = 200, refresh = 10, cores = 4)
#' }
li_stan <- function(fw, m_prey, m_pred, ...) {
  stopifnot(is(fw, "matrix"))
  stopifnot(is(m_prey, "numeric"))
  stopifnot(is(m_pred, "numeric"))
  m_prey <- matrix(m_prey, nrow = nrow(fw), ncol = ncol(fw))
  m_pred <- matrix(m_prey, nrow = nrow(fw), ncol = ncol(fw), byrow = TRUE)
  basals <- which(colSums(fw) == 0)
  if (length(basals) > 0) {
    m_prey <- m_prey[, -basals]
    m_pred <- m_pred[, -basals]
    fw <- fw[, -basals]
  }
  standata <- list(
    N = length(fw),
    link = as.vector(fw),
    mi = as.vector(m_pred),
    mr = as.vector(m_pred / m_prey)
  )
  out <- sampling(stanmodels$li, data = standata, ...)
  return (out)
}

#' Predict Using Li Model
#'
#' @importFrom rstan extract
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
#' m_prey <- log10(seq(1.1, 1e2, length.out = 10))
#' m_pred <- log10(seq(1.1, 1e2, length.out = 10))
#' mus <- seq(0.5, 1.5, length.out = 10)
#' sigmas <- seq_len(10) / 1e2
#' thetas <- sqrt(seq_len(10) / 10)
#' p <- matrix(NA, nrow = 10, ncol = 10)
#' for (i in seq_along(m_pred)) {
#'   p[, i] <- thetas[i] * exp( -(m_pred[i] / m_prey - mus[i])^2 / (2 * sigmas[i]^2))
#' }
#' fw <- matrix(rbinom(10^2, 1, p), nrow = 10, ncol = 10, byrow = TRUE)
#' image(fw)
#' fit <- li_stan(fw, m_prey, m_pred, warmup = 100, iter = 200, refresh = 10, cores = 4)
#' preds <- li_predict(fit, m_prey, m_pred)
#' }
li_predict <- function(
  fit,
  m_prey,
  m_pred,
  samples = 300
) {
  stopifnot(is(fit), "stanfit")
  stopifnot(is(m_prey, "numeric"))
  stopifnot(is(m_pred, "numeric"))
  stopifnot(is(samples), "numeric")
  # logit <- function(x) 1 / (1 + exp(-x))
  m_prey <- matrix(m_prey, nrow = length(m_prey), ncol = length(m_pred))
  m_pred <- matrix(m_prey, nrow = length(m_prey), ncol = length(m_pred), byrow = TRUE)
  posterior <- rstan::extract(fit, c(
    "alpha0", "alpha1",
    "beta0", "beta1",
    "gamma0", "gamma1"
  ))
  posterior <- do.call(cbind, posterior)
  posterior <- posterior[sample(seq_len(nrow(posterior)), samples), ]
  posterior <- as.data.frame(posterior)
  p <- array(NA, dim = c(nrow(m_prey), ncol(m_pred), samples))
  for (i in seq_len(samples)) {
    mus <- with(posterior[i, ], alpha0 + alpha1 * m_pred)
    sigmas <- with(posterior[i, ], exp(beta0 + beta1 * m_pred))
    thetas <- with(
      posterior[i, ],
      exp((gamma0 + gamma1 * m_pred)/(1 + exp(gamma0 + gamma1 * m_pred)))
    )
    p[, , i] <- thetas * exp( -(m_pred / m_prey - mus)^2 / (2 * sigmas^2))
  }
  p_mean <- apply(p, MARGIN = c(1, 2), mean)
  p_sd <- apply(p, MARGIN = c(1, 2), sd)
  return (list(mean = p_mean, sd = p_sd))
}
