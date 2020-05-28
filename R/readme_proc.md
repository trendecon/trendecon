# Readme about proc functions

All functions which start with prefix `proc_` operate on the file system. They run in the following order (sub-list
 items are functions which are
 called by a list item):

0. If for a keyword, no data has ever been downloaded, run `proc_keyword_init({keyword})`, where `{keyword}` is
 replaced by the actual keyword character vector.

1. `proc_keyword({keyword})`
    1. `proc_keyword_latest(keyword = {keyword})`
    2. `proc_aggregate(keyword = {keyword})`
        1. `proc_aggregate_windows(keyword = {keyword})`
    3. `proc_combine_freq(keyword = {keyword})`
    4. `proc_seas_adj(keyword = {keyword})`

The function `proc_all` calls scripts in folder `./inst/script` which each call `proc_keyword` for a vector of
 keywords related to a particular topic.