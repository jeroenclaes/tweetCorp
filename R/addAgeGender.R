#' Function to enrich a filtered corpus with Twitter users' most likely age and gender, based on baby names statistics
#'@description This function crossreferences the 'name' field in the corpus files with a large database of baby names statistics, drawn from two sources: United States Social Security (included in the R package 'babynames' by Hadley Wickham) and the Spanish Instituto Nacional de Estadisticas (INE). The function implements a cascade system, attempting first to find exact matches, after which it results to approximate string matching using Levenhstein distance.
#' @param filteredCorpus filtered corpus. Do not use on unfiltered data if you want to get results in this century.
#' @param maxDistance maximum Levenhstein distance to use for approximate string matching. Defaults to 2
#' @param nthreads number of threads to use in the C++ code for approximate string matching. Defaults to the number of CPU cores on your machine and it's probably a good idea to use that default.
#' @return a data.frame with the two added columns: gender (column 'sex') and most likely year of birth (column 'year')
#' @export
#' @import Rcpp
#' @import RcppProgress
#' @import readr
#' @import dplyr
#' @import parallel
#' @import stringi

addAgeGender<-function(filteredCorpus, language=c("English", "Spanish"), maxDistance=2, nthreads=parallel::detectCores()) {
  language<-match.arg(language)
  database<-switch(language, English=english_baby_names, Spanish=spanish_baby_names)

  filtered_corpus <- filtered_corpus %>%
    mutate(name=sapply(name, FUN=function(x) stri_split_boundaries(stri_trim(x))[[1]][1]))

  exactMatches<-filtered_corpus %>%
    left_join(database, by="name")


  toBeCompleted<- exactMatches %>%
    filter(is.na(year)) %>%
    select(-year, -sex)

  key<-data.frame(name=unique(toBeCompleted$name), output=fuzzyMatch(unique(toBeCompleted$name), database$name, maxDistance = maxDistance, nthreads = nthreads))

  toBeCompleted<-toBeCompleted %>%
    left_join(key, by="name") %>%
    select(-name) %>%
    rename(output=full_name) %>%
    left_join(database)

  exactMatches<-exactMatches %>%
    filter(!is.na(year))
  done<-  dplyr::bind_rows(toBeCompleted, exactMatches)

  return(done)

}
