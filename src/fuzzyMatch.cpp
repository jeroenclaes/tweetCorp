#include <Rcpp.h>
#ifdef _OPENMP
#include <omp.h>
// [[Rcpp::plugins(openmp)]]
#endif
using namespace Rcpp;
// [[Rcpp::depends(RcppProgress)]]
#include <progress.hpp>
#include <progress_bar.hpp>
// [[Rcpp::export]]
Rcpp::StringVector fuzzyMatch(Rcpp::StringVector needles, Rcpp::StringVector haystack, unsigned int maxDistance, unsigned int nthreads=1, bool displayProgress=true)
{
  Rcpp::StringVector output(needles.size()); 
  unsigned int needleLength=needles.size();
  unsigned int haystackLength=haystack.size();
#ifdef _OPENMP
  omp_set_num_threads( nthreads );
#endif
  Progress::Progress p(needles.size(), displayProgress);
#pragma omp parallel for shared(needles,haystack, needleLength, haystackLength, p) schedule(dynamic)
  for(unsigned int a=0; a<needleLength; ++a){
    for(unsigned int y=0; y<haystackLength;++y){
      if (!Progress::check_abort() ) {
      
        const std::size_t len1 = needles(a).size(), len2 = haystack(y).size();
     std::vector<std::vector<unsigned int>> d(len1 + 1, std::vector<unsigned int>(len2 + 1));
       d[0][0] = 0;
      for(unsigned int i = 1; i <= len1; ++i)  {
         d[i][0] = i;
        }
        for(unsigned int i = 1; i <= len2; ++i) {
          d[0][i] = i;
      }
       for(unsigned int i = 1; i <= len1; ++i) {
           for(unsigned int j = 1; j <= len2; ++j) {
        d[i][j] = std::min(std::min(d[i - 1][j] + 1, d[i][j - 1] + 1), d[i - 1][j - 1] + (needles(a)[i - 1] == haystack(y)[j - 1] ? 0 : 1) );
        }
      }
     if( d[len1][len2]<= maxDistance ) {
       output(a) = haystack(y);
       p.increment();
       break;
     }
     } 
    }
  }
  
 return output; 
}



