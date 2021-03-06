#' Simple function to write logs with timestamps to stderr
#'
#' @param string The message
#' @param verbose Verbosity: if TRUE, the function will print the message, if FALSE the function will do nothing at all
#'
#' @return None. The message with an added timestamp will be written to stderr
#' @export
#'
#' @examples
logmessage <- function(string, verbose=T) {
if(isTRUE(verbose)) {
  write(paste(Sys.time(),  string, sep=": "), file=stderr())
  }
}
