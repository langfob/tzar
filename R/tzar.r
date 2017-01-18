#' tzar: Package for emulating tzar code-running tool from inside R.
#'
#' This package contains the R code required for emulating running the tzar
#' code-running tool so that you get the tzar setup, file naming, and parameter
#' file building without fully running tzar.  This allows you to run your code
#' inside of R or RStudio in a way that allows you to do debugging, which is
#' difficult or impossible to do when tzar has control of the entire process,
#' e.g., on a remote machine.
#'
#' A brief overview of the package and how to use it can be found in the README
#' file at: \url{https://github.com/langfob/tzar}
#'
#' More background information on how the tzar package does the emulation can
#' also be found in the vignette, which can be accessed by typing
#' \code{vignette('tzar')}
#'
#' The tzar code-running tool itself is documented at and downloadable from:
#' \url{https://tzar-framework.atlassian.net/wiki/display/TD/Tzar+documentation}
#'
#' @docType package
#' @name tzar
NULL
