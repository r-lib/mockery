context("Mock objects")

test_that("mock single brackets", {
  m <- mock(1)
  m()
  expect_equal(mock_calls(m)[[1]], bquote(m()))
})


test_that("mock length", {
  m <- mock(1, cycle = TRUE)
  expect_equal(length(m), 0)

  m()
  expect_equal(length(m), 1)

  m()
  m()
  expect_equal(length(m), 3)
})


test_that("mock cyclic returns", {
  m <- mock(1, cycle = TRUE)
  expect_equal(lapply(1:10, m), as.list(rep(1, 10)))

  m <- mock(1, 2, cycle = TRUE)
  expect_equal(lapply(1:10, m), as.list(rep(1:2, 5)))

  m <- mock(1, 2, 3, cycle = TRUE)
  expect_equal(lapply(1:12, m), as.list(rep(1:3, 4)))
})


test_that("call list", {
  m <- mock()
  e <- environment(m)

  with_mock(summary = m, {
    summary(iris)
  })

  expect_true(exists('calls', envir = e))
  expect_length(e$calls, 1)
  expect_equal(e$calls[[1]], bquote(summary(iris)))
})


test_that("expect calls", {
  m <- mock()

  with_mock(summary = m, {
    summary(iris)
  })

  expect_call(m, 1, summary(iris))
})


test_that("error for long call is formatted well", {
  m <- mock()
  with_mock(`utils::read.table` = m, {
    read.csv('file.csv')
  })

  # test mock with mock, how crazy is that!
  # we cannot call expect_failure because it messes up calls to expect()
  # thus we intercept calls to expect() and later compare arguments
  test_mock <- mock(TRUE, TRUE)
  with_mock(expect = test_mock, {
    expect_call(m, 1, x)
  })

  expect_called(test_mock, 2)
  
  err <- paste0(
    'expected call x does not mach actual call ',
    'read.table(file = file, header = header, sep = sep, quote = quote, ',
    'dec = dec, fill = fill, comment.char = comment.char).'
  )
  expect_args(test_mock, 2, FALSE, err)
})

test_that("empty return list", {
  m <- mock()
  expect_null(m())
})


test_that("too many calls", {
  m <- mock(1)
  expect_equal(1, m())
  expect_failure(m(), "too many calls to mock object and cycle set to FALSE")
})


test_that("return expression", {
  e <- new.env(parent = globalenv())
  m <- mock(fun_x("a"),
            fun_x("a") == "a",
            envir = e, cycle = TRUE)

  e$fun_x <- function(x)x
  expect_equal(m(), "a")
  expect_true(m())

  e$fun_x <- function(x)"abc"
  expect_equal(m(), "abc")
  expect_false(m())
})


test_that("operator $ works for mock", {
  m <- mock()
  expect_equal(mock_calls(m), list())
  expect_equal(mock_args(m), list())
})


test_that("arguments are recorded", {
  m <- mock()
  m(x = 1)
  m(y = 2, z = iris)

  expect_equal(length(m), 2)
  expect_named(mock_args(m)[[1]], 'x')
  expect_named(mock_args(m)[[2]], c('y', 'z'))

  expect_equal(mock_args(m)[[1]]$x, 1)
  expect_equal(mock_args(m)[[2]]$y, 2)
  expect_equal(mock_args(m)[[2]]$z, iris)
})


test_that("expect args", {
  m <- mock()
  m(iris)
  m(x = 1)

  # compares values, not symbols
  y <- 2
  z <- iris
  m(y = y, z = z)

  expect_args(m, 1, iris)
  expect_args(m, 2, x = 1)
  expect_args(m, 3, y = 2, z = iris)
})


test_that("expect args in with_mock", {
  m <- mock()

  with_mock(lm = m, {
    x <- iris
    lm(Sepal.Width ~ Sepal.Length, data = x)
  })

  expect_args(m, 1, Sepal.Width ~ Sepal.Length, data = iris)
})


test_that("calls are counted", {
  m <- mock()
  expect_called(m, 0)

  m()
  expect_called(m, 1)

  m()
  expect_called(m, 2)
})


test_that("appropriate message if counts are missing", {
  m <- mock()
  expect_failure(expect_called(m, 1), "mock object has not been called 1 time")
  expect_failure(expect_called(m, 2), "mock object has not been called 2 times")
})

