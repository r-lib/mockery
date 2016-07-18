context('get_function_source')

test_that('gets oneline function source', {
    # given
    func = function(x) x
    expected = 'function(x) x'

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
    expected = 'function(x) { x }'

    # when
    result = get_function_source(func)

    # then
    expect_equal(trimws(result), expected)
})

