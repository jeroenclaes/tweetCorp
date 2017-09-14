#' Function to generate summary statistics for a Twitter corpus
#'
#' @param corpus_directory path to the directory where you keep the corpus CSV files. With trailing slash
#'
#' @return a data.frame that enumerates per file the number of tweets, the number of users, and the number of words
#' @export
#' @import dplyr
#' @import parallel
#' @import stringi
#' @import readr
#'
corpusStatistics<-function(corpus_directory) {

  options(mc.cores=parallel::detectCores())
  files<-list.files(corpus_directory, ".csv")
  statistics<-lapply(files, FUN=function(x) {
    dat<-read_csv(paste0(corpus_directory, x))
    nwords<-sum(stringi::stri_count_boundaries(dat$text), na.rm=T)
    file=x


    data.frame(file=x, nTweets=nrow(dat), nUsers=n_distinct(dat$screen_name), nwords=nwords, stringsAsFactors = F)

  }) %>%
    bind_rows()

  return(statistics)
}
