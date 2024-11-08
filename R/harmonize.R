#' Get GBIF Taxonomy
#'
#' @importFrom rgbif name_backbone_checklist
#' @importFrom methods is
#'
#' @export
#' @param sp Character vector of species names.
#' @return A data.frame object returned by `rbif::name_backbone_checklist`.
#' 
#' @details This function takes some time and it's needed only once. I ran
#' it and saved the output as backbone.rda in the data folder. You can
#' access it 
#'
#' @example
#' \dontrun{
#' sp <- c(
#'  amphibians$species,
#'  birds$species,
#'  mammals$species,
#'  reptiles$species,
#'  tetraeu$prey,
#'  tetraeu$predator
#' )
#' sp <- sort(unique(sp))
#' backbone <- gbif_taxonomy(sp)
#' table(backbone$original != backbone$gbif)
#' usethis::use_data(backbone, overwrite = TRUE)
#' }
gbif_taxonomy <- function(sp) {
	stopifnot(is(sp, "character"))
	taxonomy <- name_backbone_checklist(sp)[c("canonicalName", "status", "class")]
	taxonomy[["gbif"]] <- taxonomy[["canonicalName"]]
	taxonomy[["original"]] <- sp
	taxonomy <- taxonomy[, c("original", "gbif", "class", "status")]
	return (taxonomy)
}

#' Harmonize Taxonomy
#'
#' @importFrom methods is
#'
#' @export
#' @param backbone Character vector of taxonomic backbone.
#' @param datasets List of datasetes to harmonize.
#' @param species_cols Character vector of the column names with species names.
#' @return A list of the harmonized datasets.
#'
harmonize <- function(
	backbone,
	datasets,
	species_cols = rep("species", length(datasets))
) {
	stopifnot(is(datasets, "list"))
	for (i in seq_along(datasets)) {
		harm <- sapply(datasets[[i]][["species"]], \(x) {
			backbone[backbone[["original"]] == x, "gbif"]
		})
		harm <- as.vector(unlist(harm))
		datasets[[i]][["species"]] <- harm
		if (any(is.na(datasets[[i]][["species"]]))) {
			message(
				" - ", sum(is.na(datasets[[i]][["species"]])),
				" species not found in dataset ", i, "."
			)
		}
		datasets[[i]] <- subset(datasets[[i]], !is.na("species"))
	}
	return (datasets)
}
