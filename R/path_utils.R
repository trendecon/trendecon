# proc functions work on the file system

#' Build paths from base directory
#'
#' The base directory is obtained by `getOption("path_trendecon")`. If the
#' option is not present, the base directory defaults to the parent directory
#' of the current working directory. To set the option, run
#'
#'     options(path_trendecon = "~/path/to/base/dir")
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
  base <- getOption("path_trendecon", default = normalizePath("."))
  fs::path(base, ...)
}


# all subdirectoryies are specified here. Don't mention any subdirs in the code


# dir to store the individual draws. Not stricly needed but useful for research.
path_draws <- function(...) {
  path_trendecon("indicator_raw", ...)
}

# dir to store the raw data
path_raw <- function(...) {
  path_trendecon("indicator", ...)
}

# dir to store the daily data for download. Uses this name, because we link
# there from the website.
# FIXME set up a user friendly system to download series for DE AT CH at all freqs.
path_daily <- function(...) {
  path_trendecon("daily", ...)
}



# #' Build paths from `data-raw` directory
# #'
# #' @param ... Character vector of subdirectories relative to the `data-raw`
# #'     directory.
# #'
# #' @return The full path to the `data-raw` directory, or (if provided as a
# #' parameter), the path to the subdirectory.
# #' @seealso [path_trendecon]
# #' @export
# path_data_raw <- function(...) {
#   path_trendecon(...)
# }

# #' Build paths from `data` directory
# #'
# #' @param ... Character vector of subdirectories relative to the `data`
# #'     directory.
# #'
# #' @return The full path to the `data` directory, or (if provided as a
# #' parameter), the path to the subdirectory.
# #' @seealso [path_trendecon]
# #' @export
# path_data <- function(...) {
#   message("deprecated use of path_data()")
#   path_trendecon("..", "data", ...)
# }


create_data_dirs <- function(){
  message("Creating data directories if not there.")
  dir.create(path_trendecon(), showWarnings = FALSE)
  # dir.create(file.path(path_data()), showWarnings = FALSE)
  dir.create(path_daily(), showWarnings = FALSE)
  dir.create(path_draws(), showWarnings = FALSE)
  dir.create(path_raw(), showWarnings = FALSE)
}

#' Build path to indicator data file
#'
#' Builds path to indicator files of the form
#' `/{base_dir}/data-raw/indicator/{keyword}_{suffix}.csv`.
#'
#' @param keyword Keyword (character vector) for which to construct the path
#'     to the indicator.
#' @param suffix Character vector for file suffix.
#' @seealso [path_trendecon]
#' @export
path_keyword <- function(keyword, suffix) {
  normalizePath(path_raw(paste0(keyword, "_", suffix, ".csv")), mustWork = FALSE)
}

# read_keyword("Insolvenz")
read_keyword <- function(keyword, suffix = "sa") {
  readr::read_csv(path_keyword(keyword, suffix), col_types = cols())
}

#' Read keyword indicator data from disk
#'
#' Reads keyword indicators from csv files from
#' `/{base_dir}/data-raw/indicator/{keyword}_{suffix}.csv` where `{keyword}`
#' is one of the keywords in parameter `keywords`.
#'
#' @param keywords A vector of keywords.
#' @param suffix Suffix in file names, defaults to `"sa"`. Common for all
#'     keywords.
#' @param id Category id, defaults to `NULL`.
#'
#' @return A tibble with columns `keyword`, `time`, `value`.
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

#' Write csv file for keyword indicator
#'
#' Writes csv file for keyword indicator to
#' `/{base_dir}/data-raw/indicator/{keyword}_{suffix}.csv`.
#'
#' @param x Tibble of data to write to file.
#' @param suffix Character vector for file suffix, defaults to `"sa"`.
#' @inheritParams path_keyword
#' @seealso [path_keyword]
#' @export
write_keyword <- function(x, keyword, suffix = "sa") {
  write_csv(x, path_keyword(keyword, suffix))
}
