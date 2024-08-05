#' Load TetraEU Metaweb
#'
#' @export
#' @return The adjacency matrix of TetraEU.
#'
load_tetraeu <- function() {
	web <- hattian::tetraeu
	web <- .tetraeu_matrix()
	isolated <- which(rowSums(web) == 0 & colSums(web) == 0)
	if (length(isolated) > 0) {
		message("Removing isolated species...")
		web <- web[-isolated, -isolated]
	}
	return (web)
}
