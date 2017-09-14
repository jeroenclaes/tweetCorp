#' \code{syntaxNetR} a basic R binding for Google SyntaxNet Parsey Universal
#' @description Basic R binding to use an adapted version of the example python code provided by Google to tag R character vectors. You will need a Mac/Linux computer with an installation of syntaxNet to use this function. Follow the steps described here:https://github.com/tensorflow/models/tree/master/syntaxnet.
#' @param tokenVector a character vector formatted in UTF-8 or ASCII. It will almost certainly not work with windows/ISO 8591-1/latin1 encoding.
#' @param syntaxNetPath path to your local syntaxNet installation, with trailing slashes (i.e., the path has to end with a forward slash)
#' @param language name of the language  model provided by Google, must be one of pre-set options
#' @param SIMPLIFY if set to TRUE (default), the function will simplify the list output to text with slashtags (e.g., _noun_sg_nsubj)
#' @param verbose if set to TRUE (default) the function will output log messages allowing you to track its progress
#'
#' @return a parsed character vector (if SIMPLIFY is set to TRUE) or a list representation of the parsed character vector
#' @export
#' @import rPython
#' @import rjson
#' @import stringi
#' @import dplyr
#' @import parallel

syntaxNetR<-function(tokenVector, syntaxNetPath=NULL, language=c("Ancient_Greek-PROIEL","Ancient_Greek","Arabic","Basque","Bulgarian","Catalan","Chinese","Croatian","Czech-CAC","Czech-CLTT","Czech","Danish","Dutch-LassySmall","Dutch","English-LinES","English","Estonian","Finnish-FTB","Finnish","French","Galician","German","Gothic","Greek","Hebrew","Hindi","Hungarian","Indonesian","Irish","Italian","Kazakh","Latin-ITTB","Latin-PROIEL","Latin","Latvian","Norwegian","Old_Church_Slavonic","Persian","Polish","Portuguese-BR","Portuguese","Romanian","Russian-SynTagRus","Russian","Slovenian-SST","Slovenian","Spanish-AnCora","Spanish","Swedish-LinES","Swedish","Tamil","Turkish"), SIMPLIFY=TRUE,  verbose=TRUE) {
  language<-match.arg(language)
  if(is.null(syntaxNetPath)) {
    stop("Provide the path to your syntaxNet installation.")
  }

  options(mc.cores=detectCores(), stringsAsFactors = F)
  logmessage("Preprocessing data", verbose)
  tokenVector<- stringi::stri_replace_all_regex(tokenVector, "(https:\\/\\/t.co\\/)([a-z0-9A-Z]+)", "")
  tokenVector<- stringi::stri_replace_all_regex(tokenVector, "^ $", "FILLER_LINE_REMOVE_ME")

 logmessage("Writing vector", verbose)

  cat(tokenVector, file=paste0(getwd(), "/vector.txt"), sep="\n")
  rPython::python.load(system.file(package = "tweetCorp", "inst/parserJC.py"))

  logmessage("Parsing", verbose)

  parseMe<- rPython::python.call("parseVector", language, paste0(getwd(), "/vector.txt"), paste0(getwd(), "/output.json"), syntaxNetPath)

  if(parseMe=="done") {

    print(logmessage("Reading parsed file"))
    parse<- rjson::fromJSON(readLines(paste0(getwd(), "/output.json")))
    file.remove(paste0(getwd(), "/vector.txt"))
    file.remove(paste0(getwd(), "/output.json"))

    if(!isTRUE(SIMPLIFY)) {
      return(parse)
    } else {

     logmessage("Decoding parse", verbose)
      result<-unlist(parallel::mclapply(parse, FUN=function(sentences) {
        words<- sapply(sentences[[1]], FUN=function(records) {
          res <-paste(records$form,
                      records$upostag,
                      paste(records$feats[!names(records$feats) %in% c("fPOS")], collapse = "_"),
                      records$deprel,
                      sep = "_")
          return(res)
        })

        return(stringi::stri_replace_all_regex(paste(words, collapse=" "), "[:punct:]_", "_"))

      }))
     logmessage("All done", verbose)

      return(stringi::stri_trans_tolower(result))

    }
  } else {
    stop("Python hangs, sorry man.")

  }

}
