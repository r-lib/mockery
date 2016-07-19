testthat::context('stub')

a = 10
f = function(x) x
g = function(x) f(x) + a
test_that('stubs function with return value', {
    # before stubbing
    expect_equal(g(20), 30)

    # when
    stub('g', 'f', 100)

    # then
    expect_equal(g(20), 110)
})

test_that('values restored after test', {
    expect_equal(f(15), 15)
    expect_equal(g(15), 25)
})

test_that('stubs function with function', {
    # given
    a = 10
    f = function(x) x
    g = function(x) f(x) + a

    # before stubbing
    expect_equal(g(20), 30)

    # when
    stub('g', 'f', function(...) 500)

    # then
    expect_equal(g(10), 510)
})

test_that('stubs function from namespace', {
    # given
    f = function() mockery::get_function_source(function(x) x)

    # before stubbing
    expect_equal(trimws(f()), 'function(x) x')

    # when
    stub('f', 'mockery::get_function_source', 10)

    # then
    expect_equal(f(), 10)
})

test_that('does not stub other namespeaced functions', {
    # given
    f = function() {
        a = mockery::get_function_source(function(x) x)
        b = mockery::stub('a', 'b', 'c')
        return(paste(a, b))
    }

    # when
    stub('f', 'mockery::stub', 'hello there')

    # then
    expect_equal(f(), 'function(x) x\n hello there')
})
