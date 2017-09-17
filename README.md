# tweetCorp
tweetCorp: An R package to work with my Twitter corpora

This package contains functions to search, enrich, or filter a corpus consisting of CSV files. It assumes the columns that are returned by the Twitter Search API.

# Installation

To install the package, you need the package ```devtools```. You can install the package as follows:
```
#In case you don't have devtools installed
install.packages("devtools")
devtools::install_github("jeroenclaes/tweetCorp")
library(tweetCorp)
```

Mac Users may want to take the steps described in the following guide on the ```data.table``` wiki to enable OpenMP (multithreading in c++) support before installing the package. This will increase the speed of the string matching function dramatically. https://github.com/Rdatatable/data.table/wiki/Installation (under **OpenMP enabled compiler for Mac**). OpenMP may cause problems for other packages, so don't forget to revert your changes after installation!

The installation command will also install all of the package dependencies, except for Google SyntaxNet. The syntaxNetR function provides an R binding for Google SyntaxNet, but it requires that you already have syntaxnet installed on your computer. You can find the installation instructions here: https://github.com/tensorflow/models/tree/master/syntaxnet (Linux/Mac only). 

Some of the functions in the package have not yet been tested very thorougly. I would appreciate if you'd file an issue report on GitHub if you bump into any problems. 

#License
The package and the corpus itself is released under the CC BY-SA license. If you use the functions in this package or if you use the data in publications, please cite as follows:

- Claes, J. (2017). *TweetCorp: A corpus of global English tweets annotated with Google SyntaxNet*. Leuven: KU Leuven.
- Claes. J. (2017). *R package tweetCorp: A package to make working with twitter corpora easier*. Leuven KU Leuven. https://github.com/jeroenclaes/tweetCorp. 


