% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/harmonize.R
\name{gbif_taxonomy}
\alias{gbif_taxonomy}
\title{Get GBIF Taxonomy}
\usage{
gbif_taxonomy(sp)
}
\arguments{
\item{sp}{Character vector of species names.}
}
\value{
A data.frame object returned by \code{rbif::name_backbone_checklist}.
}
\description{
Get GBIF Taxonomy
}
\details{
This function takes some time and it's needed only once. I ran
it and saved the output as backbone.rda in the data folder. You can
access it
}
