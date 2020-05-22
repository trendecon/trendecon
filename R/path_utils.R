# proc functions work on the file system

#' Build paths from base directory
#'
#' The base directory is obtained by `getOption("path_trendecon")`. If the
#' option is not present, the base directory defaults to the parent directory
#' of the current working directory. To set the option, run
#' `library(R.utils)`
#'  `setOption("path_trendecon", "~/path/to/base/dir")`
#'
#' @param ... Character vector of subdirectories relative to the base
#'     directory.
#'
#' @return The full path to the base directory, or (if provided as a
#' parameter), the path to the subdirectory.
#' @seealso [R.utils::setOption]
#' @export
#' @examples
#' path_trendecon("data-raw")
#'
path_trendecon <- function(...) {
  base <- getOption("path_trendecon", default = normalizePath(".."))
  fs::path(base, ...)
}

#' Build paths from `data-raw` directory
#'
#' @param ... Character vector of subdirectories relative to the `data-raw`
#'     directory.
#'
#' @return The full path to the `data-raw` directory, or (if provided as a
#' parameter), the path to the subdirectory.
#' @seealso [path_trendecon]
#' @export
path_data_raw <- function(...) {
  path_trendecon("data-raw", ...)
}

#' @export
path_data <- function(...) {
  path_trendecon("data", ...)
}

create_data_dirs <- function(){
  message("Creating data directories if not there.")
  dir.create(file.path(path_trendecon("data-raw")), showWarnings = FALSE)
  dir.create(file.path(path_trendecon("data")), showWarnings = FALSE)
  dir.create(file.path(path_data_raw("indicator_raw")), showWarnings = FALSE)
  dir.create(file.path(path_data_raw("indicator")), showWarnings = FALSE)
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
      ans <- filter(ans, id == !!id) %>%
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
