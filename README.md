# trendecon
code to power trendecon


## TODO

Main source for inormation: http://r-pkgs.had.co.nz

### Documentation

- [ ] Roxigen header to exported functions (http://r-pkgs.had.co.nz/man.html)

- [ ] DESCRIPTION: authors, pkg summary

- [ ] Introductiory vignette (`vignettes/intro.Rmd`)

- [ ] Vignette: How to perform daily updates (see section below)

- [ ] Minimal section on getting started as `README.md`

- [ ] pkgdown website (optional) https://pkgdown.r-lib.org


### Clean Up

- [ ] Turn scripts in `inst/script` into functions. Instead of `inst/script/clothing.R`, we want to have something like `R/proc_index_clothing.R` (the later is currently just an example).

- [ ] Define (and document) the use of system paths. I think the only place where they appear is now in `path_trendecon`. Perhaps use system variables.


### Tests

- [ ] R CMD check --as-cran (optional)

- [ ] a very few tests of the basic functions (optional)



## Daily update of indices

For each index, we have a small script in `inst/script`.

To include a new series, each keyword must be initiated, which causes a lot of queries to google, so this may be called on several computers.

E.g.,
```r
library(trendecon)
proc_keyword_init("Mango")
```

Once all the keywords are initiated, the script updates the series and produces the indicator. The last line copies the data to the data repository.

To source all scripts, use:

```r
# remotes::install_local()   # build the package, only do once
gtrendecon::proc_all()
```

The first argument to `proc_all()` is the path to the `trendecon` folder, the folder that contains the repos `data` and `data-raw`. If you call it from your `gtrendecon` project, use:
```r
# remotes::install_local()   # build the package, only do once
gtrendecon::proc_all("..")
```

Updates can be performed from the command line, too:

```r
cd ~/git/trendecon/gtrendecon
rscript -e 'gtrendecon::proc_all()'
```



## Open Questions


How to auto commit stuff to the data repo? `git2r::push()` needs credentials.

```
git2r::add(path = list.files(".", recursive = TRUE))
git2r::commit(message = paste("auto data upd: ", Sys.Date()))
git2r::push()
```

How to run on a daily basis?

- Own machine?
- GitHub Actions?

