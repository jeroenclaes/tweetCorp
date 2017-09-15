# tweetCorp
tweetCorp: An R package to work with my Twitter corpora

This package contains functions to search, enrich, or filter a corpus consisting of CSV files. It assumes the columns that are returned by the Twitter Search API.

# Installation

To install the corpus, you need the package ```devtools```. You can install the package as follows:
```
#In case you don't have devtools installed
install.packages("devtools")
devtools::install_github("jeroenclaes/tweetCorp")
library(tweetCorp)
```
This will also install all of the package dependencies, except for Google SyntaxNet. The syntaxNetR function provides an R binding for Google SyntaxNet, but it requires that you already have syntaxnet installed on your computer. You can find the installation instructions here: https://github.com/tensorflow/models/tree/master/syntaxnet (Linux/Mac only). 

Some of the functions in the package have not yet been tested very thorougly. I would appreciate if you'd file an issue report on GitHub if you bump into any problems. 


