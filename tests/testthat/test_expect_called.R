testthat::context('expect_called')

test_that('expect called verifies call list', {
    # given
    g = function(y, z, x) y + z + x + 10
    f = function(x) g(y=1, z=2, x=(x + 1))

    # expect
    mockery::expect_called(f, 'g', list(y=1, z=2, x=6))

    # when
    f(5)
})

test_that('expect called verifies with partial call list', {
    # given
    g = function(y, z, x) y + z + x + 10
    f = function(x) g(y=1, z=2, x=(x + 1))

    # expect
    mockery::expect_called(f, 'g', list(y=1, x=6))

    # when
    f(5)
})

test_that('expect called verifies with unnamed call list', {
    # given
    g = function(y, z, x) y + z + x + 10
    f = function(x) g(y=1, z=2, x=(x + 1))

    # expect
    mockery::expect_called(f, 'g', list(1, 2, 6))

    # when
    f(5)
})

test_that('expect called works with namespaced funtions', {
    # given
    g = function(x, y) testthat::expect_equal(x, y)

    # expect
    mockery::expect_called(g, 'testthat::expect_equal', list(1, 1))

    # when
    g(1, 1)
})

test_that('expect called with multiple functions', {
    # given
    f = function(x) 1
    g = function(x) 1
    h = function(x) f(x) + g(x)

    # expect
    mockery::expect_called(h, 'f', list(1))
    mockery::expect_called(h, 'g', list(1))

    # when
    h(1)
})

test_that('expect called with multiple namespaced functions', {
    # given
    f = function(x) testthat::expect_equal(x) + mockery::stub(x)

    # expect
    stub(f, 'mockery::stub', 1)
    stub(f, 'testthat::expect_equal', 1)
    mockery::expect_called(f, 'mockery::stub', list(1))
    mockery::expect_called(f, 'testthat::expect_equal', list(1))

    # when
    result = f(1)

    # then
    testthat::expect_equal(2, result)
})
