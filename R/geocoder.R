#' Title \code{geocoder}: a function to geocode tweets by approximate string matching
#' @description The function will first try to find exact matches for the full_names column of the corpus in the full_names column of the geoNames_output_file, which will automatically be enriched with a database of geocoded Twitter locations from an earlier project. For the records that do not provide an exact match, it will then perform approximate string matching based on Levenhstein distance. The first string in the GeoNames_output_file full_names column to match with a distance of less than maxDistance will be returned.This is done in multithreaded C++ code, so it should be reasonably fast even for larger vectors. Matching the one million strings with one million candidates takes about thirty minutes on my MacBook Pro.
#' @param filtered_corpus Output of searchCorpus
#' @param GeoNames_output_file csv file produced with the function GeoNames()
#' @param maxDistance Maximum Levenhstein distance to use for approximate string matching. Defaults to 2 (i.e., max 2 deletions/insertions from input string to output string)
#' @param nthreads Number of threads to use for the approximate string matching. Defaults to the number of CPUs available on your machine.
#'
#' @return data.frame lat, lon columns filled in based on the geoNames_output_file
#' @export
#' @import Rcpp
#' @import RcppProgress
#' @import readr
#' @import dplyr
#' @import parallel
#' @import stringi

geocoder<-function(filtered_corpus, GeoNames_output_file, maxDistance=1, nthreads=parallel::detectCores()) {

  geoNames<-readr::read_csv(GeoNames_output_file) %>%
    bind_rows(geocodes) %>%
    group_by(full_name)
  filtered_corpus <- filtered_corpus %>%
    mutate(full_name=ifelse(is.na(full_name), location, full_name)) %>%
    mutate(lon=ifelse(!is.na(place_lon), place_lon, lon), lat= ifelse(!is.na(place_lat), place_lat, lat)) %>%
    mutate(full_name=stri_replace_all_regex(stri_replace_all_regex(full_name,"[[:punct:]]", " "), "[ ]+", " ")) %>%
    mutate(full_name=sapply(full_name, FUN=function(x) {
      split<-stri_split_boundaries(stri_trim(x))
      if(split[[1]][1] %in% c("el", "las", "the", "los", "la", "les", "a", "new", "nueva")) {
        return(paste(split[[1]][1], split[[1]][2]))
      } else {
        split[[1]][1]
      }

    }))

  exactMatches<-filtered_corpus %>%
    filter(is.na(lon) | is.na(lat)) %>%
    select(-lon, -lat) %>%
    left_join(geoNames)

  toBeCompleted<- exactMatches %>%
    filter(is.na(lon) | is.na(lat)) %>%
    select(-lon, -lat)

  key<-data.frame(full_name=unique(toBeCompleted$full_name), output=fuzzyMatch(unique(toBeCompleted$full_name), geoNames$full_name, maxDistance = maxDistance, nthreads = nthreads))

  toBeCompleted<-toBeCompleted %>%
    left_join(key, by="full_name") %>%
    select(-full_name) %>%
    rename(output=full_name) %>%
    left_join(geoNames)

  exactMatches<-exactMatches %>%
    filter(is.na(lon) | is.na(lat))
  done<- filtered_corpus %>%
    filter(!is.na(lon) | !is.na(lat)) %>%
    bind_rows(toBeCompleted, exactMatches)

  return(done)
}
