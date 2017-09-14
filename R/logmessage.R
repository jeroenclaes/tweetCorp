#' Simple function to generate logs with timestamps
#'
#' @param string The message
#' @param verbose Verbosity: if TRUE, the function will print the message, if FALSE the function will do nothing at all
#'
#' @return None. The message with an added timestamp will be printed to the screen
#' @export
#'
#' @examples
logmessage <- function(string, verbose=T) {
  if(isTRUE(verbose)) {

  print(paste(Sys.time(),  string, sep=": "))
  }
}
