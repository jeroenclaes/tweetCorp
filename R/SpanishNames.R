#' Function to create a babynames statistics database for Spanish names
#'
#' @return a babynames statistics database, listing for each name the most likely gender and year of birth
#' @param verbose if TRUE generate verbose output
#' @export
#' @import httr
#' @import dplyr
#' @import rvest
#' @import stringi
#' @import readr

SpanishNames<-function(verbose=T) {

  dir.create(paste0(getwd(), "/temp"))
  setwd(paste0(getwd(), "/temp"))
lapply(seq(from=1920, to=2010, by=10), FUN=function(x) {
  logmessage(x, verbose)
  #MALES
  males<-POST("http://www.ine.es/tnombres/formGeneralresult.do?vista=3", body=list(cmb4="00", cmb10=as.character(x), cmb7="1", btnBuscar="btnBuscar"))
  males<-content(males) %>%
    html_nodes(xpath="//table[@summary='resultados']") %>%
    html_table()

  males<- select(males[[1]], Nombre, Total)
  males$Total<-stri_replace_all_fixed(males$Total, ".", "")
  males$sex<-"M"
  males$Nombre<-stri_trans_tolower(males$Nombre)
  males$year=as.character(x)
  colnames(males)<-c("name", "n", "sex","year")
  write_csv(males, paste0("INE_",x,"_male.csv"))

  #Females
  females<-POST("http://www.ine.es/tnombres/formGeneralresult.do?vista=3", body=list(cmb4="00", cmb10=as.character(x), cmb7="6", btnBuscar="btnBuscar"))
  females<-content(females) %>%
    html_nodes(xpath="//table[@summary='resultados']") %>%
    html_table()

  females<- select(females[[1]], Nombre, Total)
  females$Total<-stri_replace_all_fixed(females$Total, ".", "")
  females$sex<-"F"
  females$Nombre<-stri_trans_tolower(females$Nombre)
  females$year=as.character(x)
  colnames(females)<-c("name", "n", "sex","year")
  write_csv(females, paste0("INE_",x,"_female.csv"))

})


spanish_baby_names<- lapply(list.files(getwd(), ".csv"), FUN=function(x) {
  readr::read_csv(x, col_types=cols(
    name = col_character(),
    n = col_integer(),
    sex = col_character(),
    year = col_integer()
  ))}) %>%
      bind_rows()
spanish_baby_names$name<-sapply(spanish_baby_names$name, FUN=function(x) {
  stri_split_fixed(x, " ")[[1]][1]
}) %>%
  stri_trim()
spanish_baby_names<-spanish_baby_names %>%
 filter(year!=1920) %>%
filter(year!=2010) %>%
  ungroup() %>%
 group_by(name, year, sex) %>%
  summarise(n=sum(as.numeric(n))) %>%
 ungroup()%>%
   group_by(name) %>%
mutate(prob=n/sum(as.numeric(n))) %>%
  filter(prob==max(prob))

unlink(paste0(getwd(), "/temp"), recursive=T)
return(spanish_baby_names)
}
