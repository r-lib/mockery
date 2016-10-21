
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


#' @param where The function to be called that will in turn call
#'        \code{what}.
#' @param what The name of the function you want to stub out,
#'        \code{character} or \code{symbol}.
#' @param how Replacement function (also a \code{\link{mock}} function)
#'        or a return value for which a function will be created
#'        automatically.
#' 
#' @export
#' @rdname stub
#' 
#' @examples
#' \dontrun{
#' stub(read.csv, 'read.table', function(...) TRUE)
#' read.csv('data.csv')
#' 
#' # which is equivalent to
#' stub(read.csv, read.table, TRUE)
#' }
#' 
`stub` <- function (where, what, how)
{
    # `where` needs to be a function
    where_name <- deparse(substitute(where))
    stopifnot(is.function(where))
  
    # `what` can be either a symbol or a character value
    what_name  <- substitute(what)
    if (is.symbol(what_name) || identical(what_name, `::`)) {
      what_name <- deparse(what_name)
    }
    else {
      stopifnot(is.character(what), length(what) == 1)
      what_name <- what
    }

    # this is where a stub is going to be assigned in
    env <- new.env(parent = environment(where))

    if (grepl('::', what_name)) {
        elements  <- strsplit(what_name, '::')
        what_name <- paste(elements[[1]][1], elements[[1]][2], sep='XXX')

        stub_list <- c(what_name)
        if ("stub_list" %in% names(attributes(get('::', env)))) {
            stub_list <- c(stub_list, attributes(get('::', env))[['stub_list']])
        }

        create_new_name <- create_create_new_name_function(stub_list, env)
        assign('::', create_new_name, env)
    }

    if (!is.function(how)) {
        assign(what_name, function(...) how, env)
    } else {
        assign(what_name, how, env)
    }

    environment(where) <- env
    assign(where_name, where, parent.frame())
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

