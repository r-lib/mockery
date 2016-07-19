library(restorepoint)
library(testthat)

# Works with named or unnamed call list.
# If unnamed, must be complete call list, if named can be partial.
expect_called = function(func, to_mock, expected_call_list) {
    func_name = deparse(substitute(func))
    original_env = restorepoint::clone.environment(environment(func))

    if (grepl('::', to_mock)) {
        mock_func = eval(parse(text=to_mock))
        elements = strsplit(to_mock, '::')
        to_mock = paste(elements[[1]][1], elements[[1]][2], sep='XXX')

        create_new_name = create_create_new_name_function(to_mock, original_env)
        assign('::', create_new_name, original_env)
    } else {
        mock_func = get(to_mock, original_env)
    }

    mock_env = restorepoint::clone.environment(environment(mock_func))

    expect_call_equal = function(call_list) {
        if (length(names(expected_call_list)) != 0) {
            call_list = call_list[names(expected_call_list)]
        } else {
            call_list = tail(call_list, -1)
        }
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

    environment(func) = original_env
    assign(func_name, func, parent.frame())
}

