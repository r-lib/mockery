#' R package to make mocking easier
#'
#' There are great tools for unit testing in R out there already but
#' they don't come with a lot of support for mock objects. This
#' package aims at fixing that.
#'
#' @docType package
#' @aliases mockery-package
#' @name mockery
#'
#' @examples
#' library(mockery)
#' 
#' m <- mock(TRUE, FALSE, TRUE)
#' 
#' # this will make summary call our mock function rather then
#' # UseMethod; thus, summary() will return values as above
#' stub(summary, 'UseMethod', m)
#' 
#' summary(iris) # returns TRUE
#' summary(cars) # returns FALSE
#' summary(co2)  # returns TRUE
#' 
#' \dontrun{
#' library(testthat)
#' 
#' m <- mock(TRUE)
#' f <- function() read.csv('data.csv')
#' 
#' with_mock(read.csv = m, {
#'   f()
#'   expect_call(m, 1, read.csv('data.csv'))
#' })
#' }
NULL