#' Read keywords for index from json file
#'
#' Reads the keywords from which a specific index is built form the given
#' json file.
#'
#' @param json_file A character vector with the path to the json file with
#'     index-specific keywords
#' @param idx A character vector with the name of the index (as in the json
#' file)
#'
#' @example
#' keywords <- read_index_json("keywords/keywords_ch.json", "clothing")

library(jsonlite)

read_index_json <- function(json_file, idx){
  json <- fromJSON(txt = json_file)
  keywords <- json %>% filter(index==idx) %>% pull(keywords) %>% unlist()
  return(keywords)
}