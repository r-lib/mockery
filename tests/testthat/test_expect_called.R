testthat::context('expect_called')

test_that('adds start and end brackets', {
    # given
    output = c('function(x=list()) x')

    # when
    result = add_brackets(output)

    # then
    expect_equal(result, c('function(x=list()) {', ' x', '}'))
})

test_that('expect called verifies call list', {
    # given
    g = function(y, z, x) y + z + x + 10
    f = function(x) g(y=1, z=2, x=(x + 1))

    # expect
    expect_called('f', 'g', list(y=1, z=2, x=6))

    # when
    f(5)
})
