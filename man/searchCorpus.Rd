% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/searchCorpus.R
\name{searchCorpus}
\alias{searchCorpus}
\title{Simple example function to extract data from the corpus}
\usage{
searchCorpus(pattern, corpus_directory, output_directory = NULL,
  field = c("tagged", "text"))
}
\arguments{
\item{pattern}{word or regular expression}

\item{corpus_directory}{directory where you keep the corpus file}

\item{output_directory}{directory where you want the output files to go. Keep to NULL (default) if you want to collect the results in an R object rather than writing them out to files}

\item{field}{one of 'tagged' or 'text'. If you want to search the parsed data, opt for 'tagged', otherwise, opt for 'text'}
}
\value{
Either a data.frame or nothing
}
\description{
There is a real risk of overflowing your computer's memory if you search for a frequent pattern in the files. If you specify an output directory, the results out kept out of memory. Linux/Mac users may want to use the command line tool 'grep' instead of this function, as it will be much faster. e.g. \code{grep [PATTERN] corpus_directory/*csv > outputfile.csv}. Information on POS and dependency labels:http://universaldependencies.org/format.html.
}
