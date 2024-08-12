#' @title Random Forest model
#' 
#' @importFrom randomForest randomForest
#' @export
#' @param fw Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @param masses Numeric vector of the species' body mass.
#' @param ... Arguments passed to `randomForest` (e.g. ntree, mtry).
#' @return An object of class `randomForest` returned by 
#'  randomForest::randomForest`
random_forest <- function(fw, masses) {
  stopifnot(is(fw, "matrix"))
  stopifnot(is(masses, "numeric"))
  basals <- which(colSums(fw) == 0)
  m_prey <- matrix(masses, nrow = nrow(fw), ncol = ncol(fw))
  m_pred <- matrix(masses, nrow = nrow(fw), ncol = ncol(fw), byrow = TRUE)
  basals <- which(colSums(fw) == 0)
  if (length(basals) > 0) {
    m_prey <- m_prey[, -basals]
    m_pred <- m_pred[, -basals]
    fw <- fw[, -basals]
  }
  mr <- as.vector(log10(m_pred / m_prey))
  links <- as.factor(as.vector(fw))
  rf <- randomForest(links ~ mr, ...)
  return (rf)
}