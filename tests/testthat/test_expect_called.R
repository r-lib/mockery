testthat::context('expect_called')

test_that('expect called verifies call list', {
    # given
    g = function(y, z, x) y + z + x + 10
    f = function(x) g(y=1, z=2, x=(x + 1))

    # expect
    mockery::expect_called('f', 'g', list(y=1, z=2, x=6))

    # when
    f(5)
})

test_that('expect called verifies with partial call list', {
    # given
    g = function(y, z, x) y + z + x + 10
    f = function(x) g(y=1, z=2, x=(x + 1))

    # expect
    mockery::expect_called('f', 'g', list(y=1, x=6))

    # when
    f(5)
})

test_that('expect called works with namespaced funtions', {
    # given
    g = function(x, y) testthat::expect_equal(x, y)

    # expect
    mockery::expect_called('g', 'testthat::expect_equal', list(1, 1))

    # when
    g(1, 1)
})
