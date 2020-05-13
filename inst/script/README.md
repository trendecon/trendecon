## Daily update of indices

For each index, we have a small script in `inst/script`.

To include a new series, each keyword must be initiated, which causes a lot of queries to google, so this may be called on several computers.

E.g.,
```r
library(gtrendecon)
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



