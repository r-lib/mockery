
#' Create and query a mocked function.
#'
#' Mock object's primary use is to record calls that are made on the
#' mocked function.
#'
#' Optionally values/expressions can be passed via \code{...} for the
#' mock object to return them upon subsequent calls. Expressions are
#' evaluated in environment \code{envir} before being returned. If no
#' value is passed in \code{...} then \code{NULL} is returned.
#'
#' Passing an expression or a function call via \code{...} is also a
#' way to implement side effects: keep track of the state of code
#' under testing, throw an exception when a condition is met, etc.
#'
#' \code{mock_calls} and \code{mock_args} can be used to access the
#' list of calls made on a mocked function and a respective list of
#' values of arguments passed to each of these calls.
#'
#'
#' @param ... Values returned upon subsequent calls.
#' @param cycle Whether to cycle over the return values. If \code{FALSE},
#'        will fail if called too many times.
#' @param envir Where to evaluate the expressions being returned.
#' @param m A \code{\link{mock}}ed function.
#' @param x A \code{\link{mock}}ed function.
#'
#' @return \code{mock()} returns a mocked function which can be then used
#'         with \code{\link{with_mock}}.
#' @return \code{mock_args()} returns a \code{list} of \code{list}s
#'         of argument values.
#' @return \code{mock_calls()} returns a \code{list} of \code{call}s.
#' @return \code{length.mock()} returns the number of calls invoked on \code{m}.
#'
#' @examples
#' library(testthat)
#'
#' m <- mock(1)
#' with_mock(summary = m, {
#'   expect_equal(summary(iris), 1)
#'   expect_no_calls(m, 1)
#'   expect_call(m, 1, summary(iris))
#'   expect_args(m, 1, iris)
#' })
#'
#' # multiple return values
#' m <- mock(1, "a", sqrt(3))
#' with_mock(summary = m, {
#'   expect_equal(summary(iris), 1)
#'   expect_equal(summary(iris), "a")
#'   expect_equal(summary(iris), 1.73, tolerance = .01)
#' })
#'
#' # side effects
#' m <- mock(1, 2, stop("error"))
#' with_mock(summary = m, {
#'   expect_equal(summary(iris), 1)
#'   expect_equal(summary(iris), 2)
#'   expect_error(summary(iris), "error")
#' })
#'
#' # accessing call expressions
#' m <- mock()
#' m(x = 1)
#' m(y = 2)
#' expect_equal(length(m), 2)
#' calls <- mock_calls(m)
#' expect_equal(calls[[1]], quote(m(x = 1)))
#' expect_equal(calls[[2]], quote(m(y = 2)))
#'
#' # accessing values of arguments
#' m <- mock()
#' m(x = 1)
#' m(y = 2)
#' expect_equal(length(m), 2)
#' args <- mock_args(m)
#' expect_equal(args[[1]], list(x = 1))
#' expect_equal(args[[2]], list(y = 2))
#'
#'
#' @name mock
NULL


#' @export
#' @rdname mock
#'
#' @importFrom testthat fail
mock <- function (..., cycle = FALSE, envir = parent.frame()) {
  stopifnot(is.environment(envir))

  return_values     <- eval(substitute(alist(...)))
  return_values_env <- envir
  call_no           <- 0
  calls             <- list()
  args              <- list()

  mock_impl <- function(...) {
    call_no <<- call_no + 1
    calls[[call_no]] <<- match.call()

    args[[call_no]] <<- list(...)

    if (length(return_values)) {
      if (call_no > length(return_values) && !cycle)
        fail("too many calls to mock object and cycle set to FALSE")

      value <- return_values[[(call_no - 1) %% length(return_values) + 1]]
      return(eval(value, envir = return_values_env))
    }

    # TODO maybe it should the mock object itself?
    invisible(NULL)
  }

  class(mock_impl) <- 'mock'
  mock_impl
}


#' @export
#' @rdname mock
mock_args <- function (m) {
  stopifnot(is_mock(m))
  environment(m)$args
}


#' @export
#' @rdname mock
mock_calls <- function (m) {
  stopifnot(is_mock(m))
  environment(m)$calls
}


is_mock <- function (object) inherits(object, 'mock')


#' @export
#' @rdname mock
length.mock <- function (x)
{
  length(environment(x)$calls)
}

