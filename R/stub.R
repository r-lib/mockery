stub = function(func, to_stub, stub) {
    original_func = get(func, envir=parent.frame(), mode='function')
    env = environment(original_func)

    if (mode(stub) == 'function') {
        assign(to_stub, stub, env)
    } else {
        assign(to_stub, function(...) return(stub), env)
    }

    function_text = get_function_source(original_func)
    new_function = eval(parse(text=function_text), env)
    assign(func, new_function, parent.frame())
}

