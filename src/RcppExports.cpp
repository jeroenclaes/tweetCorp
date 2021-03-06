// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// fuzzyMatch
Rcpp::StringVector fuzzyMatch(Rcpp::StringVector needles, Rcpp::StringVector haystack, unsigned int maxDistance, unsigned int nthreads, bool displayProgress);
RcppExport SEXP _tweetCorp_fuzzyMatch(SEXP needlesSEXP, SEXP haystackSEXP, SEXP maxDistanceSEXP, SEXP nthreadsSEXP, SEXP displayProgressSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::StringVector >::type needles(needlesSEXP);
    Rcpp::traits::input_parameter< Rcpp::StringVector >::type haystack(haystackSEXP);
    Rcpp::traits::input_parameter< unsigned int >::type maxDistance(maxDistanceSEXP);
    Rcpp::traits::input_parameter< unsigned int >::type nthreads(nthreadsSEXP);
    Rcpp::traits::input_parameter< bool >::type displayProgress(displayProgressSEXP);
    rcpp_result_gen = Rcpp::wrap(fuzzyMatch(needles, haystack, maxDistance, nthreads, displayProgress));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_tweetCorp_fuzzyMatch", (DL_FUNC) &_tweetCorp_fuzzyMatch, 5},
    {NULL, NULL, 0}
};

RcppExport void R_init_tweetCorp(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
