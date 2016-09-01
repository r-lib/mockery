stub = function(func, to_stub, stub) {
    func_name = deparse(substitute(func))
    env = new.env(parent=environment(func))

    if (grepl('::', to_stub)) {
        elements = strsplit(to_stub, '::')
        to_stub = paste(elements[[1]][1], elements[[1]][2], sep='XXX')

        stub_list = c(to_stub)
        if ("stub_list" %in% names(attributes(get('::', env)))) {
            stub_list = c(stub_list, attributes(get('::', env))[['stub_list']])
        }

        create_new_name = create_create_new_name_function(stub_list, env)
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

create_create_new_name_function = function(stub_list, env) {
    create_new_name = function(pkg, func) {
        pkg_name = deparse(substitute(pkg))
        func_name = deparse(substitute(func))
        for(stub in stub_list) {
            if (paste(pkg_name, func_name, sep='XXX') == stub) {
                return(eval(parse(text=stub), env))
            }
        }
        return(eval(parse(text=paste(pkg_name, func_name, sep='::'))))
    }
    attributes(create_new_name) = list(stub_list=stub_list)
    return(create_new_name)
}

