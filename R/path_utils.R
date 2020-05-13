# proc functions work on the file system

#' @export
path_trendecon <- function(...) {
  base <- getOption("path_trendecon", default = normalizePath(".."))
  fs::path(base, ...)
}

#' @export
path_data_raw <- function(...) {
  path_trendecon("data-raw", ...)
}

#' @export
path_data <- function(...) {
  path_trendecon("data", ...)
}



#' @export
path_keyword <- function(keyword, suffix) {
  normalizePath(path_data_raw("indicator", paste0(keyword, "_", suffix, ".csv")), mustWork = FALSE)
}

# read_keyword("Insolvenz")
read_keyword <- function(keyword, suffix = "sa") {
  read_csv(path_keyword(keyword, suffix), col_types = cols())
}

#' @export
read_keywords <- function(keywords, suffix = "sa", id = NULL) {
  read_keywords_one <- function(keyword) {
    ans <-
      read_keyword(keyword, suffix = suffix) %>%
      mutate(keyword = keyword) %>%
      select(keyword, id, time, value)

    if (!is.null(id)) {
      ans <- filter(ans, id == !! id) %>%
        select(-id)
    }
    ans
  }
  bind_rows(lapply(keywords, read_keywords_one))
}

#' @export
write_keyword <- function(x, keyword, suffix = "sa") {
  write_csv(x, path_keyword(keyword, suffix))
}

