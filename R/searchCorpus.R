#' Simple example function to extract data from the corpus
#' @description There is a real risk of overflowing your computer's memory if you search for a frequent pattern in the files. If you specify an output directory, the results out kept out of memory. Linux/Mac users may want to use the command line tool 'grep' instead of this function, as it will be much faster. e.g. \code{grep [PATTERN] corpus_directory/*csv > outputfile.csv}. Information on POS and dependency labels:http://universaldependencies.org/format.html.
#' @param pattern word or regular expression
#' @param corpus_directory directory where you keep the corpus file
#' @param output_directory directory where you want the output files to go. Keep to NULL (default) if you want to collect the results in an R object rather than writing them out to files
#' @param field one of 'tagged' or 'text'. If you want to search the parsed data, opt for 'tagged', otherwise, opt for 'text'
#'
#' @return Either a data.frame or nothing
#' @export
#'@import dplyr
#'@import readr
#'@import stringi
#'@import parallel
searchCorpus<-function(pattern, corpus_directory, output_directory=NULL, field=c("tagged", "text")) {

  field<-match.arg(field)

  #Options
  options(mc.cores=detectCores(), stringsAsFactors = F)

  #Logic
  search<-parallel::mclapply(list.files(corpus_directory, ".csv"), FUN=function(x) {
   file<- readr::read_csv(paste0(corpus_directory,"/", x), col_types = cols(
      created_at = col_character(),
      id_str = col_double(),
      name = col_character(),
      screen_name = col_character(),
      location = col_character(),
      full_name = col_character(),
      lon = col_double(),
      lat = col_double(),
      place_lon = col_double(),
      place_lat = col_double(),
      text = col_character(),
      tagged = col_character()
    ))

   if(field=="tagged") {
     file<-file %>%
       filter(grepl(pattern, tagged, perl=T))

   }else {
     file<-file %>%
       filter(grepl(pattern, text, perl=T))
   }

    if(!is.null(output_directory)) {
      readr::write_csv(file, paste0(output_directory,"/", x))
     return(NULL)
   } else {
     return(file)
   }

  })

  #Output
  if(!is.null(output_directory)) {
    return(paste("Searched corpus field", shQuote(field), "of the corpus files in directory", shQuote(corpus_directory), "and written output to", shQuote(output_directory)))
  } else {
    return(bind_rows(search))
  }

}
