library(restorepoint)

stub = function(func, to_stub, stub) {
    original_func = get(func, envir=parent.frame(), mode='function')
    env = restorepoint::clone.environment(environment(original_func))

    if (grepl('::', to_stub)) {
        create_new_name = function(pkg, func) {
            pkg_name = deparse(substitute(pkg))
            func_name = deparse(substitute(func))
            if (paste(pkg_name, func_name, sep='XXX') == to_stub) {
                return(eval(parse(text=to_stub), env))
            }
            return(eval(parse(text=paste(pkg_name, func_name, sep='::'))))
        }
        assign('::', create_new_name, env)
        elements = strsplit(to_stub, '::')
        to_stub = paste(elements[[1]][1], elements[[1]][2], sep='XXX')
    }

    if (mode(stub) != 'function') {
        assign(to_stub, function(...) stub, env)
    } else {
        assign(to_stub, stub, env)
    }

    environment(original_func) = env
    assign(func, original_func, parent.frame())
}

