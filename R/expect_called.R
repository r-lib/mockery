library(restorepoint)
library(testthat)

expect_called = function(func, to_mock, expected_call_list) {
    original_func = get(func, envir=parent.frame(), mode='function')
    original_env = restorepoint::clone.environment(environment(original_func))
    mock_func = get(to_mock, original_env)
    mock_env = restorepoint::clone.environment(environment(mock_func))

    expect_call_equal = function(call_list) {
        call_list = call_list[names(expected_call_list)]
        call_list = lapply(names(call_list),
                           function(x) eval(parse(text=x), parent.frame(3)))
        names(call_list) = names(expected_call_list)
        testthat::expect_equal(call_list, expected_call_list)
    }

    assign('expect_call_equal', expect_call_equal, mock_env)

    function_source = get_function_source(mock_func)
    function_source = add_first_statement(function_source, 'expect_call_equal(as.list(match.call()))')

    mocked_function = eval(parse(text=function_source), mock_env)
    assign(to_mock, mocked_function, original_env)

    environment(original_func) = original_env
    assign(func, original_func, parent.frame())
}

