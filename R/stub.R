library(restorepoint)

stub = function(func, to_stub, stub) {
    func_name = deparse(substitute(func))
    env = restorepoint::clone.environment(environment(func))

    if (grepl('::', to_stub)) {
        elements = strsplit(to_stub, '::')
        to_stub = paste(elements[[1]][1], elements[[1]][2], sep='XXX')

        create_new_name = create_create_new_name_function(to_stub, env)
        assign('::', create_new_name, env)
    }

    if (mode(stub) != 'function') {
        assign(to_stub, function(...) stub, env)
    } else {
        assign(to_stub, stub, env)
    }

    environment(func) = env
    assign(func_name, func, parent.frame())
}

create_create_new_name_function = function(to_stub, env) {
    create_new_name = function(pkg, func) {
        pkg_name = deparse(substitute(pkg))
        func_name = deparse(substitute(func))
        if (paste(pkg_name, func_name, sep='XXX') == to_stub) {
            return(eval(parse(text=to_stub), env))
        }
        return(eval(parse(text=paste(pkg_name, func_name, sep='::'))))
    }
    return(create_new_name)
}

