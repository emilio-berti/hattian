#' Li et al. (2024) model.
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
#' fit <- li_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
li_stan <- function(fw, m_prey, m_pred, ...) {
  standata <- list(
    N = length(fw),
    S = ncol(fw),
    B = sum(colSums(fw) == 0),
    link = as.vector(fw),
    mi = as.vector(m_prey),
    mr = as.vector(m_prey / m_pred),
    s = rep(seq_len(ncol(fw)), each = nrow(fw))
  )
  out <- rstan::sampling(stanmodels$li, data = standata, ...)
  return (out)
}
# install.packages("../hattian/", type="source", repos=NULL)