testthat::context('get_function_source')

test_that('adds start and end brackets', {
    # given
    output = c('function(x=list()) x')

    # when
    result = add_brackets(output)

    # then
    expect_equal(result, c('function(x=list())', '{', ' x', '}'))
})

test_that('gets oneline function source', {
    # given
    func = function(x) x
    expected = 'function(x)\n{\nx\n}'

    # when
    result = get_function_source(func)

    # then
    expect_equal(trimws(result), expected)
})

test_that('gets multiline function source', {
    # given
    func = function(x) {
        x
    }
    expected = 'function(x) {\nx\n}'

    # when
    result = get_function_source(func)

    # then
    expect_equal(trimws(result), expected)
})

test_that('gets source for namespaced functions', {
    # given
    expected = get_function_source(get_function_source)

    # when
    result = get_function_source(mockery::get_function_source)

    # then
    expect_equal(result, expected)
})

test_that('add first statement', {
    # given
    function_source = 'function(x) {x}'

    # when
    result = add_first_statement(function_source, 'y')

    # then
    expect_equal(result, 'function(x) {\n y \nx}')
})
