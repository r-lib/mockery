get_function_source = function(func) {
    output = capture.output(print(func))

    # drops environment and namespace information
    filtered_output = Filter(function(x) !startsWith(trimws(x), '<'), output)

    cleaned_output = sapply(filtered_output, trimws)
    function_source = paste(cleaned_output, set='', collapse='')
    return(function_source)
}

