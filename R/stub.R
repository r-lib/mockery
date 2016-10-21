
#' Replace a function with a stub.
#'
#' The result of calling \code{stub} is that, when \code{func}
#' is invoked and when it internally makes a call to \code{to_stub},
#' \code{stub} is going to be called instead.
#' 
#' This is much more limited in scope in comparison to
#' \code{\link[testthat]{with_mock}} which effectively replaces
#' \code{to_stub} everywhere. In other words, when using \code{with_mock}
#' and regardless of the number of intermediate calls, \code{stub} is
#' always called instead of \code{to_stub}. However, using this API,
#' the replacement takes place only for a single function \code{func}
#' and only for calls originating from that function.
#' 
#' \code{remote_stub} reverses the effect of \code{stub}.
#' 
#' @name stub
#' @rdname stub
NULL


#' @param func The function to be called that will in turn call \code{to_stub}
#' @param to_stub The name of the function you want to stub out.
#' @param stub Replacement function or a return value.
#' 
#' @export
#' @rdname stub
#' 
#' @examples
#' \dontrun{
#' stub(read.csv, 'read.table', function(...) TRUE)
#' read.csv('data.csv')
#' }
#' 
`stub` <- function (func, to_stub, stub)
{
    func_name <- deparse(substitute(func))
    env <- new.env(parent=environment(func))

    if (grepl('::', to_stub)) {
        elements <- strsplit(to_stub, '::')
        to_stub <- paste(elements[[1]][1], elements[[1]][2], sep='XXX')

        stub_list = c(to_stub)
        if ("stub_list" %in% names(attributes(get('::', env)))) {
            stub_list <- c(stub_list, attributes(get('::', env))[['stub_list']])
        }

        create_new_name <- create_create_new_name_function(stub_list, env)
        assign('::', create_new_name, env)
    }

    if (!is.function(stub)) {
        assign(to_stub, function(...) stub, env)
    } else {
        assign(to_stub, stub, env)
    }

    environment(func) = env
    assign(func_name, func, parent.frame())
}


# @param where Reverse changes made for that function.
# @param what Remove this stub.
# 
# @rdname stub
# @export
`remove_stub` <- function (where, what)
{
  stop('not implemented yet', call. = FALSE)
  
  # 1. remove if exists, abort if it doesn't exist
  # 2. if the intermediate environment is empty, remove it
}



create_create_new_name_function <- function(stub_list, env)
{
    create_new_name <- function(pkg, func)
    {
        pkg_name  <- deparse(substitute(pkg))
        func_name <- deparse(substitute(func))
        for(stub in stub_list) {
            if (paste(pkg_name, func_name, sep='XXX') == stub) {
                return(eval(parse(text = stub), env))
            }
        }
        return(eval(parse(text=paste(pkg_name, func_name, sep='::'))))
    }
    attributes(create_new_name) <- list(stub_list=stub_list)
    return(create_new_name)
}

