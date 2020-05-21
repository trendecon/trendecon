# Code to Power trendecon.org

During the Covid-19 pandemic, information and the (economic and social) situation has changed rapidly. Traditional (economic) indicators are not sufficiently frequent to monitor and forecast (economic and social) activity at high frequency. We use Google search trends to overcome this data gap and create meaningful indicators. We extract daily search data on keywords reflecting consumers' perception of the economic situation.


## TODO


Main source for inormation: http://r-pkgs.had.co.nz

### Documentation

- [ ] Roxigen header to exported functions (http://r-pkgs.had.co.nz/man.html)

- [ ] DESCRIPTION: authors, pkg summary

- [ ] Introductiory vignette (`vignettes/intro.Rmd`) (http://r-pkgs.had.co.nz/vignettes.html)

- [ ] Vignette: How to perform daily updates (see section below)

- [ ] Minimal section on getting started as `README.md`

- [ ] pkgdown website (optional) https://pkgdown.r-lib.org


### Clean Up

- [ ] Turn scripts in `inst/script` into functions. Instead of `inst/script/clothing.R`, we want to have something like `R/proc_index_clothing.R` (the later is currently just an example).

- [ ] Define (and document) the use of system paths. I think the only place where they appear is now in `path_trendecon`. Perhaps use system variables.


### Tests

- [ ] R CMD check --as-cran (optional)

- [ ] a very few tests of the basic functions (optional)



