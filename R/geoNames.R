#' GeoNames: function to create a geonames database file from geonames.org export
#' @description This function will create a geonames database file which includes alternative spellings of many placenames. The function reads/munges a lot of data, so give it some time.
#' @param GeoNames_file download/unzip this file http://download.geonames.org/export/dump/allCountries.zip and specify its path (e.g. GeoNames_file="~/Downloads/allCountries.txt")
#' @param AlternateNames_file  download/unzip this file http://download.geonames.org/export/dump/alternateNames.zip and specify its path
#' @param output_file Where should the output go? Defaults to the current working directory/GeoNames_outputfile.csv
#'
#' @return A message signaling completion. The actual result is not returned but rather written to a CSV file
#' @export
#' @import readr
#' @import dplyr
#' @import stringi

GeoNames<-function(GeoNames_file, AlternateNames_file, output_file=paste0(getwd(),"/GeoNames_outputfile.csv")) {
  geoNames<-suppressWarnings(read_tsv(GeoNames_file, col_names = c("id", "full_name", "full_name2", "alternate names", "lat", "lon"), col_types=cols(id=col_character(), full_name=col_character(), full_name2=col_character(), lat=col_double(), lon=col_double()))) %>%
    select(-full_name2, -`alternate names`)

  alternateNames<-suppressWarnings(read_tsv(AlternateNames_file, col_names = c("id_name", "id", "lang","full_name"), col_types=cols(id_name=col_character(),id=col_character(), lang=col_character(), full_name=col_character()))) %>%
    select(-id_name)  %>%
    filter(lang!="link") %>%
    select(-lang) %>%
    mutate(lat=NA, lon=NA)

  names<-bind_rows(geoNames, alternateNames) %>%
    group_by(id) %>%
    mutate(lon=lon[which(!is.na(lon))][1], lat=lat[which(!is.na(lat))][1]) %>%
    ungroup() %>%
    group_by(id, full_name) %>%
    slice(1) %>%
    ungroup() %>%
    select(-id) %>%
    mutate(full_name=stri_trans_tolower(full_name)) %>%
    filter(!is.na(lat))

  write_csv(names, output_file)
  return(paste("Merged files and written the output to", output_file))
}

