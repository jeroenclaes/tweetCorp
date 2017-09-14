#' Function to clean up common encoding issues
#'
#' @param character.vector Character vector or string you want to clean up
#'
#' @return cleaned character vector
#' @export
#'@import stringi
#'@import dplyr

cleanupText <- function(characterVector)
{

  character.vector <- as.character(character.vector)
  character.vector <-
    stri_replace_all_fixed(character.vector, "â", "") %>%
    stri_replace_all_fixed("Ã¡", "á") %>%
    stri_replace_all_fixed("Ã©", "é") %>%
    stri_replace_all_fixed("Ã³", "ó") %>%
    stri_replace_all_fixed("Ãº", "ú") %>%
    stri_replace_all_fixed("Ã±", "ñ") %>%
    stri_replace_all_fixed("Ã£", "ã") %>%
    stri_replace_all_fixed("Ã¼", "ü") %>%
    stri_replace_all_fixed("Ã¶", "ö") %>%
    stri_replace_all_fixed("Ã¤", "ä") %>%
    stri_replace_all_fixed("Ã¥", "å") %>%
    stri_replace_all_fixed("Ã¸", "ø") %>%
    stri_replace_all_fixed("Ã®", "î") %>%
    stri_replace_all_fixed("Ã¢", "â") %>%
    stri_replace_all_fixed("Ãª", "ê") %>%
    stri_replace_all_fixed("Ã¨", "è") %>%
    stri_replace_all_fixed("Ã§", "ç") %>%
    stri_replace_all_fixed("Ã",  "í") %>%
    stri_replace_all_regex("[\\u00B7|\\uf0b7|\\uf0a0|\\u00AD]", "") %>%
    stri_replace_all_fixed("habia", "había") %>%
    stri_replace_all_fixed("habian", "habían") %>%
    stri_replace_all_fixed("habra", "habrá") %>%
    stri_replace_all_fixed("habran", "habrán") %>%
    stri_replace_all_regex("[^[:print:]]", "") %>%
    stri_replace_all_regex("  +", " ") %>%
    stri_trans_tolower()
  return(character.vector)
}
