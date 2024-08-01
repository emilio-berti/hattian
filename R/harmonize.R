#' Get GBIF Taxonomy
#'
#' @export
#' @param sp Character vector of species names.
#' @param ... Arguments passed to `rbif::name_backbone_checklist` (e.g. strict).
#' @return A data.frame object returned by `rbif::name_backbone_checklist`.
#' 
#' @details This function takes some time and it's needed only once. I ran
#'  it and saved the output as backbone.rda in the data folder. You can
#'  access it 
#'
gbif_taxonomy <- function(sp) {
	taxonomy <- name_backbone_checklist(sp)[c("canonicalName", "status")]
	taxonomy[["gbif"]] <- taxonomy[["canonicalName"]]
	taxonomy[["original"]] <- sp
	taxonomy <- taxonomy[, c("original", "gbif", "status")]
	return (taxonomy)
}

#' Harmonize Taxonomy
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
		datasets[[i]][["species"]] <- harm
		if (any(is.na(datasets[[i]][["species"]]))) {
			message(
				" - ", sum(is.na(datasets[[i]][["species"]])),
				" species not found in dataset ", i, "."
			)
		}
		datasets[[i]] <- subset(datasets[[i]], !is.na(species))
	}
	return (datasets)
}
