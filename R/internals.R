#' Convert TetraEU into Matrix
#'
#' @importFrom utils data
#'
#' @return A matrix version of TetraEU.
#'
#' @details This function is internal and, in theory, should not be called directly.
#'
.tetraeu_matrix <- function() {
	tetraeu <- NULL #silence NOTE on global variable
	data("tetraeu", envir = environment())
	sp <- sort(with(tetraeu, union(prey, predator)))
	metaweb <- matrix(0, nrow = length(sp), ncol = length(sp))
	dimnames(metaweb) <- list(sp, sp)
	# The following loop needs to use tetraeu within a `with` 
	# statement. Threat carefully.
	for (x in sp) {
		metaweb[with(tetraeu, prey[predator == x]), x] <- 1
	}
	return (metaweb)
}