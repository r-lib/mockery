get_function_source = function(func) {
    output = capture.output(print(func))

    # drops environment and namespace information
    output = Filter(function(x) !startsWith(trimws(x), '<'), output)

    output = add_brackets(output)
    output = sapply(output, trimws)
    function_source = paste(output, sep='\n', set='', collapse='')
    return(function_source)
}

add_first_statement = function(function_source, statement) {
    return(sub('\\{', paste('{\n', statement, '\n'), function_source))
}

add_brackets = function(output) {
    if (length(output) == 1) {
        last = max(gregexpr(')', output[1])[[1]])
        output = c(substr(output, 1, last), '{', substring(output, last + 1), '}')
    }
    return(output)
}
