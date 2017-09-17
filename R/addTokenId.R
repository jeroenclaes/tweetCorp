#' Function to add a unique identifier for each token to a concordance
#'
#' @param concordance a concordance generated with makeConcordance
#'
#' @return a concordance data.frame, with a tokenId column added
#' @export
#' @import dplyr

addTokenId<-function(concordance) {

concordance %>% group_by(id_str) %>%
    mutate(tokenId=unique(paste(id_str, 1:n(),sep="_#")))


}
