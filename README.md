
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hattian

<!-- badges: start -->

<!-- badges: end -->

The goal of hattian is to model energy fluxes worldwide applying the
conceptual workflow from Antunes et al. (2024).

## Installation

You can install the development version of hattian from
[GitHub](https://github.com/) with:

``` r
devtools::install_github("emilio-berti/hattian")
```

hattian depends on big packages, such as stan and Rcpp, and it takes
some time to install. Be patient…

Load the package:

``` r
library(hattian)
```

# Datasets included in hattian

Hattian comes with \# datasets:

1.  `mammals`, the body mass (g) of mammals EltonTraits.
2.  `birds`, the body mass (g) of birds from EltonTraits.
3.  `amphibians`, the maximum body mass (g) of amphibians from AmphiBIO.
4.  `tetraeu`, the metweb of tetrapods of Europe.

From more details type `?<dataset>` in R, e.g. `?mammals`.

# Foodweb inference models

Hattian contains \# models to infer foodwebs:

1.  A scaling niche model, from Yeakel et al. (2014).
2.  A variable niche width model, from Li et al. (2023).

## Scaling niche model (Yeakel et al., 2014)

This is the simplest model implemented in hattian. The probability that
predator
![j](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;j
"j") predates on prey
![i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;i
"i") is given by their body mass ratio:   
![
P(A\_{ij} = 1) = \\frac{p}{1 + p}
](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%0AP%28A_%7Bij%7D%20%3D%201%29%20%3D%20%5Cfrac%7Bp%7D%7B1%20%2B%20p%7D%0A
"
P(A_{ij} = 1) = \\frac{p}{1 + p}
")  
where   
![
p = exp( a\_1 + a\_2 log\_{10}(\\frac{m\_j}{m\_i}) + a\_3
(log\_{10}(\\frac{m\_j}{m\_i}))^2 )
](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%0Ap%20%3D%20exp%28%20a_1%20%2B%20a_2%20log_%7B10%7D%28%5Cfrac%7Bm_j%7D%7Bm_i%7D%29%20%2B%20a_3%20%28log_%7B10%7D%28%5Cfrac%7Bm_j%7D%7Bm_i%7D%29%29%5E2%20%29%0A
"
p = exp( a_1 + a_2 log_{10}(\\frac{m_j}{m_i}) + a_3 (log_{10}(\\frac{m_j}{m_i}))^2 )
")  
and
![m\_i](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;m_i
"m_i") and
![m\_j](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;m_j
"m_j") are the body masses if prey and predator, respectively.

This model is coded in stan and is called using `yeakel_stan()`:

``` r
library(hattian)
# create community
S <- 20
m <- sort(runif(S, 1, 1e2))
fw <- matrix(NA, nrow = S, ncol = S)

# set parameters
a1 <- 1
a2 <- 3
a3 <- -10

# create web accordingly
for (j in seq_along(m)) {
  fw[, j] <- exp(a1 + a2 * log10(m[j] / m) + a3 * log10(m[j] / m)^2)
}
fw <- fw / (1 + fw)

# sample probabilities
fw <- rbinom(length(fw), 1, fw)
fw <- matrix(fw, nrow = S, ncol = S)
show_web(fw)
```

<img src="man/figures/README-yeakel-1.png" width="100%" />

``` r

# fit model
fit_yeakel <- yeakel_stan(
  fw, m,
  warmup = 250, iter = 500, #to speed up vignette
  cores = 4, refresh = 250
)
posterior <- rstan::extract(fit_yeakel, c("a1", "a2", "a3"))
oldpar <- par(no.readonly = TRUE)
par(mfrow = c(2, 2), mar = c(4, 4, 2, 2))
for (i in seq_along(posterior)) {
  plot(
    density(posterior[[i]]),
    main = names(posterior)[i],
    xlab = "Posterior"
  )
}
par(oldpar)
```

<img src="man/figures/README-yeakel-2.png" width="100%" />

## Variable niche width model (Li et al., 2023)

In this model,

# References

Antunes, A. C., Berti, E., Brose, U., Hirt, M. R., Karger, D. N.,
O’Connor, L. M., … & Gauzens, B. (2024). Linking biodiversity,
ecosystem function, and Nature’s contributions to people: a
macroecological energy flux perspective. Trends in Ecology & Evolution.
<https://doi.org/10.1016/j.tree.2024.01.004>

Li, J., Luo, M., Wang, S., Gauzens, B., Hirt, M. R., Rosenbaum, B., &
Brose, U. (2023). A size‐constrained feeding‐niche model distinguishes
predation patterns between aquatic and terrestrial food webs. Ecology
Letters, 26(1), 76-86. <https://doi.org/10.1111/ele.14134>

Yeakel, J. D., Pires, M. M., Rudolf, L., Dominy, N. J., Koch, P. L.,
Guimarães Jr, P. R., & Gross, T. (2014). Collapse of an ecological
network in Ancient Egypt. Proceedings of the National Academy of
Sciences, 111(40), 14472-14477.
<https://doi.org/10.1073/pnas.1408471111>
