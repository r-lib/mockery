
#' Replace a function with a stub.
#'
#' The result of calling \code{stub} is that, when \code{where}
#' is invoked and when it internally makes a call to \code{what},
#' \code{how} is going to be called instead.
#' 
#' This is much more limited in scope in comparison to
#' \code{\link[testthat]{with_mock}} which effectively replaces
#' \code{what} everywhere. In other words, when using \code{with_mock}
#' and regardless of the number of intermediate calls, \code{how} is
#' always called instead of \code{what}. However, using this API,
#' the replacement takes place only for a single function \code{where}
#' and only for calls originating in that function.
#' 
#' 
#' @name stub
#' @rdname stub
NULL

# \code{remote_stub} reverses the effect of \code{stub}.


#' @param where Function to be called that will in turn call
#'        \code{what}.
#' @param what Name of the function you want to stub out (a
#'        \code{character} string).
#' @param how Replacement function (also a \code{\link{mock}} function)
#'        or a return value for which a function will be created
#'        automatically.
#' @param depth Specifies the depth to which the function should be stubbed
#' 
#' @export
#' @rdname stub
#' 
#' @examples
#' f <- function() TRUE
#' g <- function() f()
#' stub(g, 'f', FALSE)
#' 
#' # now g() returns FALSE because f() has been stubbed out
#' g()
#' 
`stub` <- function (where, what, how, depth=1)
{
    # `where` needs to be a function
    where_name <- deparse(substitute(where))
  
    # `what` needs to be a character value
    stopifnot(is.character(what), length(what) == 1)

    test_env <- parent.frame()
    tree <- build_function_tree(test_env, where, where_name, depth)

    mock_through_tree(tree, what, how)
}

mock_through_tree <- function(tree, what, how) {
    for (d in tree) {
        for (parent in d) {
            parent_env = parent[['parent_env']]
            func_dict = parent[['funcs']]
            for (func_name in ls(func_dict, all.names=TRUE)) {
                func = func_dict[[func_name]]
                func_env = new.env(parent = environment(func))

                what <- override_seperators(what, func_env)
                where_name <- override_seperators(func_name, parent_env)

                if (!is.function(how)) {
                    assign(what, function(...) how, func_env)
                } else {
                    assign(what, how, func_env)
                }

                environment(func) <- func_env
                assign(where_name, func, parent_env)
            }
        }
  }
}

override_seperators = function(name, env) {
    for (sep in c('::', "\\$")) {
        if (grepl(sep, name)) {
            elements <- strsplit(name, sep)
            mangled_name <- paste(elements[[1]][1], elements[[1]][2], sep='XXX')

            if (sep == '\\$') {
                sep <- '$'
            }

            stub_list <- c(mangled_name)
            if ("stub_list" %in% names(attributes(get(sep, env)))) {
                stub_list <- c(stub_list, attributes(get(sep, env))[['stub_list']])
            }

            create_new_name <- create_create_new_name_function(stub_list, env, sep)
            assign(sep, create_new_name, env)
        }
    }
    return(if (exists('mangled_name')) mangled_name else name)
}

create_create_new_name_function <- function(stub_list, env, sep)
{
    force(stub_list)
    force(env)
    force(sep)

    create_new_name <- function(pkg, func)
    {
        pkg_name  <- deparse(substitute(pkg))
        func_name <- deparse(substitute(func))
        for(stub in stub_list) {
            if (paste(pkg_name, func_name, sep='XXX') == stub) {
                return(eval(parse(text = stub), env))
            }
        }

        # used to avoid recursively calling the replacement function
        eval_env = new.env(parent=parent.frame())
        assign(sep, eval(parse(text=paste0('`', sep, '`'))), eval_env)

        code = paste(pkg_name, func_name, sep=sep)
        return(eval(parse(text=code), eval_env))
    }
    attributes(create_new_name) <- list(stub_list=stub_list)
    return(create_new_name)
}

build_function_tree <- function(test_env, where, where_name, depth)
{
    func_dict = new.env()
    func_dict[[where_name]] = where
    tree = list(
        # one depth
        list(
            # one parent
            list(parent_env=test_env, funcs=func_dict)
        )
    )

    if (depth > 1) {
        for (d in 2:depth) {
            num_parents = 0
            new_depth = list()
            for (funcs in tree[[d - 1]]) {
                parent_dict = funcs[['funcs']]
                for (parent_name in ls(parent_dict, all.names=TRUE)) {
                    func_dict = new.env()
                    parent_env = environment(get(parent_name, parent_dict))
                    for (func_name in ls(parent_env, all.names=TRUE)) {
                        func = get(func_name, parent_env)
                        if (is.function(func)) {
                            func_dict[[func_name]] = func
                        }
                    }

                    new_parent = list(parent_env=parent_env, funcs=func_dict)
                    num_parents = num_parents + 1
                    new_depth[[num_parents]] = new_parent
                }
            }
            tree[[d]] = new_depth
        }
    }
    return(tree)
}
