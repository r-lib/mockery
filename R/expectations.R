
#' Expectation: does the given call match the expected?
#'
#' Together with \code{\link{mock}} can be used to verify whether the
#' call expression (\code{\link{expect_call}}) and/or argument values
#' (\code{\link{expect_args}}) match the expected.
#'
#' With \code{expect_called} you can check how many times has the mock
#' object been called.
#'
#' @param mock_object A \code{\link{mock}} object.
#' @param n Call number or total number of calls.
#' @param expected_call Expected call expression; will be compared unevaluated.
#' @param ... Arguments as passed in a call.
#'
#' @examples
#' library(testthat)
#' 
#' # expect call expression (signature)
#' m <- mock()
#' with_mock(summary = m, summary(iris))
#' 
#' # it has been called once
#' expect_called(m, 1)
#' 
#' # the first (and only) call's arguments matche `summary(iris)`
#' expect_call(m, 1, summary(iris))
#'
#' # expect argument value
#' m <- mock()
#' a <- iris
#' with_mock(summary = m, summary(object = a))
#' expect_args(m, 1, object = a)
#' # is an equivalent to ...
#' expect_equal(mock_args(m)[[1]], list(object = a))
#'
#' @name call-expectations
#'
NULL



#' @export
#' @rdname call-expectations
#'
#' @importFrom testthat expect
expect_call <- function (mock_object, n, expected_call) {
  stopifnot(is_mock(mock_object))

  expect(
    0 < n && n <= length(mock_object),
    sprintf("call number %s not found in mock object", toString(n))
  )

  expected_call <- substitute(expected_call)
  mocked_call <- mock_calls(mock_object)[[n]]

  expect(
    identical(mocked_call, expected_call),
    sprintf("expected call %s does not mach actual call %s.",
            format(expected_call), format(mocked_call))
  )

  invisible(TRUE)
}


#' @export
#' @rdname call-expectations
#'
#' @importFrom testthat expect expect_equal
expect_args <- function (mock_object, n, ...)
{
  stopifnot(is_mock(mock_object))

  expect(
    0 < n && n <= length(mock_object),
    sprintf("arguments list number %s not found in mock object", toString(n))
  )

  expected_args <- list(...)

  expect_equal(
    mock_args(mock_object)[[n]],
    expected_args,
    info = "expected argument list does not mach actual one."
  )

  invisible(TRUE)
}


#' @export
#' @rdname call-expectations
expect_no_calls <- function (mock_object, n)
{
  stopifnot(is_mock(mock_object))
  
  expect(
    length(mock_object) == n,
    sprintf("mock object has not been called %s times", toString(n))
  )
}
