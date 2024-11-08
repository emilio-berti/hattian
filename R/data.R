#' European Tetrapod Meta-Web
#'
#' A subset of data from TetraEU, including only adults individuals.
#' For details, see <https://doi.org/10.1111/geb.13138>.
#'
#' @format ## `tetraeu`
#' A data frame with 60,453 rows and 2 columns:
#' \describe{
#'   \item{prey}{Prey name}
#'   \item{predator}{Predator name}
#' }
#' @source <https://doi.org/10.5061/dryad.jm63xsj7b>
"tetraeu"

#' Body Mass for Mammals.
#'
#' A subset of data from EltonTraits, including only species with known body mass.
#' For details, see <https://doi.org/10.1890/13-1917.1>.
#'
#' @format ## `mammals`
#' A data frame with 4,041 rows and 2 columns:
#' \describe{
#'   \item{species}{Species name}
#'   \item{mass}{Body mass (g)}
#' }
#' @source <https://doi.org/10.5061/dryad.jm63xsj7b>
"mammals"

#' Body Mass for Birds.
#'
#' A subset of data from EltonTraits, including only species with known body mass.
#' For details, see <https://doi.org/10.1890/13-1917.1>.
#'
#' @format ## `birds`
#' A data frame with 9,123 rows and 2 columns:
#' \describe{
#'   \item{species}{Species name}
#'   \item{mass}{Body mass (g)}
#' }
#' @source <https://doi.org/10.5061/dryad.jm63xsj7b>
"birds"

#' Body Mass for Amphibians.
#'
#' A subset of data from AmphiBIO, including only species with known body mass
#' or known body length, from which body masses was imputed.
#' For details, see <https://doi.org/10.1038/sdata.2017.123>.
#'
#' @format ## `amphibians`
#' A data frame with 5,227 rows and 3 columns:
#' \describe{
#'   \item{species}{Species name}
#'   \item{mass}{Body mass (g)}
#'   \item{imputed}{Was body mass imputed using major axis regression?}
#' }
#' @source <https://doi.org/10.5061/dryad.jm63xsj7b>
"amphibians"

#' Body Mass for Reptiles
#' 
#' A subset of data from ReptTraits, oncluding only species with known body mass
#' or known body length, from whcih body masses was imputed.
#' For details, see <https://doi.org/10.1038/s41597-024-03079-5>.
#' @format ## `reptiles`
#' A data frame with 12,059 rows and 3 columns:
#' \describe{
#'   \item{species}{Species name}
#'   \item{mass}{Body mass (g)}
#'   \item{imputed}{Was body mass imputed using major axis regression?}
#' }
#' @source <https://doi.org/10.1038/s41597-024-03079-5>
"reptiles"

#' GBIF Taxonomic Backbone
#'
#' The GBIF taxonomic backbone for the species in the datasets obtained 
#' running the function `gbif_taxonomy`.
#'
#' @format ## `backbone`
#' A data frame with 30,610 rows and 3 columns:
#' \describe{
#'   \item{original}{Species name in the original dataset}
#'   \item{gbif}{Species name in GBIF backbone}
#'   \item{status}{Status of the nomenclature}
#' }
"backbone"
