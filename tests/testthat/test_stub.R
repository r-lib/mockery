context('stub')

f = function(x) x
test_that('stubs function with return value', {
    # given
    a = 10
    g = function(x) f(x) + a

    # before stubbing
    expect_equal(g(20), 30)

    # when
    stub('g', 'f', 100)

    # then
    expect_equal(g(20), 110)
})

test_that('values restored after test', {
    expect_equal(f(15), 15)
})

test_that('stubs function with function', {
    # given
    a = 10
    g = function(x) f(x) + a

    # before stubbing
    expect_equal(g(20), 30)

    # when
    stub('g', 'f', function(...) 500)

    # then
    expect_equal(g(10), 510)
})
