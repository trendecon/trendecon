
<!-- README.md is generated from README.Rmd. Please edit that file -->

## Create Daily Series from Google Trends

<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/trendecon/trendecon.svg?branch=master)](https://travis-ci.com/trendecon/trendecon)
<!-- badges: end -->

During the Covid-19 pandemic, information and the (economic and social)
situation has changed rapidly. We use Google search trends to overcome
this data gap and create meaningful indicators. We extract daily search
data on keywords reflecting consumers’ perception of the economic
situation.

The website [www.trendecon.org](https://www.trendecon.org) provides a
set of economic indicators for Switzerland based on Google search
trends. These indicators are updated daily and provide policymakers and
business leaders with timely information about the Swiss economy. Here
you find more information on how to use our indicators and you can
download the data.

This project was inititated during the
\#versusvirus\[<https://www.versusvirus.ch>\] and got
[funding](https://www.versusvirus.ch/funding) from the hackathon.

This package contains the R code to construct long daily time series
from Google Trends. Robustness of the data is achieved by query Google
mulitple times. In order to reflect the long term trends of the series,
the queries are sent at various frequencies (daily, weekly and monthy).
The actual download is done by the
[gtrendsR](https://cran.r-project.org/package=gtrendsR) package.

## Install

You can install the trendecon package from GitHub.

``` r
# install.packages("remotes")
remotes::install_github("trendecon/trendecon")
```

## Usage

To download a series from Google Trends:

``` r
library(trendecon)
x <- ts_gtrends("cinema", geo = "CH")
#> Downloading data for today+5-y
tsbox::ts_plot(x)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

## Documentation

The [introductory
vignette](https://trendecon.github.io/trendecon/articles/intro.html)
gives describes the basic use of the package.

To create and update long daily series from Google Trends, see the
[vignette on daily
series](https://trendecon.github.io/trendecon/articles/daily-series.html).

## TODO

Main source for inormation: <http://r-pkgs.had.co.nz>

### Documentation

  - \[ \] Roxigen header to exported functions
    (<http://r-pkgs.had.co.nz/man.html>)

  - \[ \] DESCRIPTION: authors, pkg summary

  - \[ \] Introductiory vignette (`vignettes/intro.Rmd`)
    (<http://r-pkgs.had.co.nz/vignettes.html>)

  - \[ \] Vignette: How to perform daily updates (see section below)

  - \[ \] Minimal section on getting started as `README.md`

  - \[ \] pkgdown website (optional) <https://pkgdown.r-lib.org>

### Clean Up

  - \[ \] Turn scripts in `inst/script` into functions. Instead of
    `inst/script/clothing.R`, we want to have something like
    `R/proc_index_clothing.R` (the later is currently just an example).

  - \[ \] Define (and document) the use of system paths. I think the
    only place where they appear is now in `path_trendecon`. Perhaps use
    system variables.

### Tests

  - \[ \] R CMD check –as-cran (optional)

  - \[ \] a very few tests of the basic functions (optional)
