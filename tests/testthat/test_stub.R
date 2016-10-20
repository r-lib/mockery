testthat::context('stub')

a = 10
f = function(x) x
g = function(x) f(x) + a
test_that('stubs function with return value', {
    # before stubbing
    expect_equal(g(20), 30)

    # when
    stub(g, 'f', 100)

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
    stub(g, 'f', function(...) 500)

    # then
    expect_equal(g(10), 510)
})

test_that('stubs function from namespace', {
    # given
    f = function() mockery::get_function_source(function(x) x)

    # before stubbing
    expect_equal(trimws(f()), 'function(x)\n{\nx\n}')

    # when
    stub(f, 'mockery::get_function_source', 10)

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
    stub(f, 'mockery::stub', 'hello there')

    # then
    expect_equal(f(), 'function(x)\n{\nx\n}\n hello there')
})

test_that('stub and mock work together', {
    # given
    f = function(x) x + 10
    g = function(x) f(x)

    # when
    stub(g, 'f', 100)
    expect_called(g, 'f', list(10))

    # then
    expect_equal(g(10), 100)
})

test_that('stub multiple functions', {
    # given
    f = function(x) x + 10
    g = function(y) y + 20
    h = function(z) f(z) + g(z)

    # when
    stub(h, 'f', 300)
    stub(h, 'g', 500)

    # then
    expect_equal(h(1), 800)
})

test_that('stub multiple namespaced functions', {
    # given
    h = function(x) mockery::stub(x) + mockery::get_function_source(x)

    # when
    stub(h, 'mockery::stub', 300)
    stub(h, 'mockery::get_function_source', 500)

    # then
    expect_equal(h(1), 800)
})

test_that('stub works well with mock object', {
    # given
    f = function(x) x + 10
    g = function(x) f(x)

    mock_object = mock(100)
    stub(g, 'f', mock_object)

    # when
    result = g(5)

    # then
    expect_equal(result, 100)
})

test_that('mock object returns value', {
    mock_object = mock(1)
    stub(g, 'f', mock) 

    expect_equal(g('anything'), 1)
    expect_no_calls(m, 1)
    expect_call(m, 1, g('anything'))
    expect_args(m, 1, iris)
})
