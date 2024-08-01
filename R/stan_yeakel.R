#' Yeakel et al. (?) model.
#'
#' @importFrom rstan extract
#'
#' @export
#' @param fw Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @param m_prey Numeric matrix of the prey body mass.
#' @param m_pred Numeric matrix of the predator body mass.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
#' @examples
#' library(hattian)
#' fw <- matrix(sample(c(0, 1), 100, replace = TRUE), nrow = 10, ncol = 10)
#' m_prey <- matrix(runif(10, 0, 1), nrow = 10, ncol = 10)
#' m_pred <- matrix(runif(10, 0, 1), nrow = 10, ncol = 10, byrow = TRUE)
#' fit <- yeakel_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
yeakel_stan <- function(fw, m_prey, m_pred, ...) {
  standata <- list(
    N = length(fw),
    link = as.vector(fw),
    mr = as.vector(m_prey / m_pred)
  )
  out <- rstan::sampling(stanmodels$yeakel, data = standata, ...)
  return (out)
}

yeakel_predict <- function(
  fit,
  m_prey,
  m_pred,
  samples = 300
) {
  logit <- function(x) 1 / (1 + exp(-x))
  posterior <- extract(fit, c("a1", "a2", "a3"))
  posterior <- do.call(cbind, posterior)
  posterior <- posterior[sample(seq_len(nrow(posterior)), samples), ]
  posterior <- as.data.frame(posterior)
  p <- array(NA, dim = c(nrow(m_prey), nrow(m_pred), samples))
  for (i in seq_len(samples)) {
    p[, , i] <- with(posterior[i, ], a1 + a2 * m_prey / m_pred + a3 * (m_prey / m_pred) ^ 2)
  }
  p <- logit(p)
  p_mean <- apply(p, MARGIN = c(1, 2), mean)
  return (p_mean)
}
