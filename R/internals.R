#' Convert TetraEU into Matrix
#'
#' @return A matrix version of TetraEU.
#'
#' @details This function is internal and, in theory, should not be called directly.
#'
.tetraeu_matrix <- function() {
	data("tetraeu", envir = environment())
	sp <- sort(union(tetraeu[["prey"]], tetraeu[["predator"]]))
	metaweb <- matrix(0, nrow = length(sp), ncol = length(sp))
	dimnames(metaweb) <- list(sp, sp)
	for (i in seq_len(nrow(tetraeu))) {
		metaweb[tetraeu[i, "prey"], tetraeu[i, "predator"]] <- 1
	}
	return (metaweb)
}