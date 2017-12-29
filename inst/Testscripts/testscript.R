#===============================================================================

                        #  testscript.R

#===============================================================================

#  testthat::test_file() fails when you're testing functions that are not
#  exported from the package when you're running the tests outside of CHECK.
#  The following stackoverflow question suggests that you source the R file(s)
#  containing the function(s) you want to test.  That way, they end up in the
#  namespace of the session where you're working and they can be called.

#-------------------------------------------------------------------------------

# https://stackoverflow.com/questions/6041079/how-can-we-test-functions-that-arent-exposed-when-building-r-packages
#
# You can test during development with the usual testthat functions because
# you're probably just sourcing in all your R code and not worrying about
# namespaces (at least that's how I develop). You then use R CMD check in
# conjunction with test_package to ensure the tests still work at build time -
# test_packages runs the tests in the package namespace so they can test
# non-exported functions.
# answered May 18 '11 at 12:36
# hadley
#

#===============================================================================

library(tzar)
library(testthat)

source('~/D/Projects/ProblemDifficulty/pkgs/tzar/R/console_sink_file_functions.R')
source('~/D/Projects/ProblemDifficulty/pkgs/tzar/R/mainline_support_functions.R')
source('~/D/Projects/ProblemDifficulty/pkgs/tzar/R/once_per_project.R')
source('~/D/Projects/ProblemDifficulty/pkgs/tzar/R/emulateRunningUnderTzar.R')
source('~/D/Projects/ProblemDifficulty/pkgs/tzar/R/model_with_possible_tzar_emulation.R')
source('~/D/Projects/ProblemDifficulty/pkgs/tzar/R/run_tzar.R')

#-------------------------------------------------------------------------------

test_file("/Users/bill/D/Projects/ProblemDifficulty/pkgs/tzar/tests/testthat/test_mainline_support_functions.R")

#===============================================================================

