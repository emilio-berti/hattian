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

#' Show Web
#'
#' @importFrom graphics image
#' @export
#' @param fw Numeric matrix of the adjacency matrix of the food web.
#'  Predators are in columns and prey in rows.
#' @return NULL
show_web <- function(fw) {
	fw <- t(apply(fw, 2, rev)) #predators on columns
	image(
		fw,
		col = c("grey20", "dodgerblue2"),
		axes = FALSE, frame = TRUE
	)
	grid(
		nx = ncol(fw), ny = nrow(fw),
		lty = 1,
		col = "grey30"
	)
}
