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

f = function(x) x + 10
g = function(x) f(x)
test_that('mock object returns value', {
    mock_object = mock(1)
    stub(g, 'f', mock_object) 

    expect_equal(g('anything'), 1)
    expect_no_calls(mock_object, 1)
    expect_args(mock_object, 1, 'anything')
})

test_that('mock object multiple return values', {
    mock_object = mock(1, "a", sqrt(3))
    stub(g, 'f', mock_object) 

    expect_equal(g('anything'), 1)
    expect_equal(g('anything'), "a")
    expect_equal(g('anything'), sqrt(3))
})
                                   
test_that('mock object accessing values of arguments', {
    mock_object <- mock()
    mock_object(x = 1)
    mock_object(y = 2)

    expect_equal(length(mock_object), 2)
    args <- mock_args(mock_object)

    expect_equal(args[[1]], list(x = 1))
    expect_equal(args[[2]], list(y = 2))
})

test_that('mock object accessing call expressions', {
    mock_object <- mock()
    mock_object(x = 1)
    mock_object(y = 2)

    expect_equal(length(mock_object), 2)
    calls <- mock_calls(mock_object)

    expect_equal(calls[[1]], quote(mock_object(x = 1)))
    expect_equal(calls[[2]], quote(mock_object(y = 2)))
})
