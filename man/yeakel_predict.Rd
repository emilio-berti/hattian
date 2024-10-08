% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stan_yeakel.R
\name{yeakel_predict}
\alias{yeakel_predict}
\title{Predict Using Yeakel Model}
\usage{
yeakel_predict(fit, m_prey, m_pred, samples = 300)
}
\arguments{
\item{fit}{Numeric matrix of the adjacency matrix of the food web.
Predators are in columns and prey in rows.}

\item{m_prey}{Numeric vector of the prey body mass.}

\item{m_pred}{Numeric vector of the predator body mass.}

\item{samples}{Numeric value of the number of samples to draw.}
}
\value{
An object of class \code{stanfit} returned by \code{rstan::sampling}
}
\description{
Predict Using Yeakel Model
}
\examples{
\dontrun{
library(hattian)
fw <- matrix(sample(c(0, 1), 100, replace = TRUE), nrow = 10, ncol = 10)
m_prey <- runif(10, 0, 1)
m_pred <- runif(10, 0, 1)
fit <- yeakel_stan(fw, m_prey, m_pred, warmup = 100, iter = 200)
}
}
