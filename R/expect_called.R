library(restorepoint)
library(testthat)

expect_called = function(func, to_mock, expected_call_list) {
    original_func = get(func, envir=parent.frame(), mode='function')
    original_env = restorepoint::clone.environment(environment(original_func))
    mock_func = get(to_mock, original_env)
    mock_env = restorepoint::clone.environment(environment(mock_func))

    expect_call_equal = function() {
        call_list = lapply(names(expected_call_list), function(x) eval(parse(text=x), parent.frame(3)))
        names(call_list) = names(expected_call_list)
        testthat::expect_equal(call_list, expected_call_list)
    }

    assign('expect_call_equal', expect_call_equal, mock_env)

    output = capture.output(print(mock_func))
    filtered_output = Filter(function(x) !startsWith(trimws(x), '<'), output)
    cleaned_output = sapply(filtered_output, trimws)

    if (length(cleaned_output) == 1) {
        cleaned_output = add_brackets(cleaned_output)
    }

    mocked_output = append(cleaned_output, 'expect_call_equal()'
                , 1)
    function_source = paste(mocked_output, sep='\n', set='', collapse='')

    mocked_function = eval(parse(text=function_source), mock_env)
    assign(to_mock, mocked_function, original_env)

    environment(original_func) = original_env
    assign(func, original_func, parent.frame())
}

add_brackets = function(output) {
    last = max(gregexpr(')', output[1])[[1]])
    first_line = paste(substr(output, 1, last), '{')
    return(c(first_line, substring(output, last + 1), '}'))
}

