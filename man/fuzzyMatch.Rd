% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{fuzzyMatch}
\alias{fuzzyMatch}
\title{Function to perform approximate string matching in multithreaded C++ code}
\usage{
fuzzyMatch(needles, haystack, maxDistance, nthreads = 1L,
  displayProgress = TRUE)
}
\arguments{
\item{needles}{character vector to match the database haystack vector against}

\item{haystack}{character vector of possible matches}

\item{maxDistance}{maximum Levenhstein distance to allow for matching}

\item{nthreads}{number of threads to use to speed up the computation. Defaults to the number of CPU cores available on your machine.}

\item{displayProgress}{display a progress bar (if TRUE)}
}
\value{
character vector of matches, which has the same length as the input vector. Input vector items for which no matching strings could be found return an empty string.
}
\description{
This function will compare two character vectors. For each combination, it will calculate the Levenhstein distance between the needle string and the haystack string. If the distance is lower than the maximum allowed distance, the search will be discontinued and the haystack string will be returned. Therefore, it is necessary to set a reasonable threshold, as the function will return the first string with a distance below the maximum distance.
}
