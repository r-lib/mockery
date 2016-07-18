stub = function(func, to_stub, return_value) {
    original_func = get(func, envir=parent.frame(), mode='function')
    env = environment(original_func)
    assign(to_stub, function(...) return(return_value), env)

    function_text = get_function_source(original_func)
    new_function = eval(parse(text=function_text), env)
    assign(func, new_function, parent.frame())
}

