#' Add expectation to a function.
#'
#' Works with named or unnamed call list. If unnamed, must be
#' a complete call list, if named can be partial.
#'
#' @param func The function you plan to call, and within which you want
#'        to verify a call to another function.
#' @param to_mock A string that is the name of the function you want to
#'        verify a call to.
#' @param expected_call_list This is the list of parameters you expect
#'        to be present in the function call. It can be a list with or
#'        without names. If it is a list with names, it can be a partial
#'        list, i.e. it doesn't need to include all the parameters. Only
#'        the included parameters will be checked.
#'
#' @importFrom utils tail
#' @export
#'
#' @examples
#' # given                                                                     
#' g <- function(y, z, x) y + z + x + 10                                        
#' f <- function(x) g(y=1, z=2, x=(x + 1))                                      
#'
#' # expect                                                                    
#' expect_called(f, 'g', list(y=1, x=6))                              
#'
#' # when                                                                      
#' f(5)   
#'
expect_called <- function(func, to_mock, expected_call_list)
{
    func_name <- deparse(substitute(func))
    original_env <- new.env(parent=environment(func))

    if (grepl('::', to_mock)) {
        mock_func <- eval(parse(text=to_mock), original_env)
        elements  <- strsplit(to_mock, '::')
        to_mock   <- paste(elements[[1]][1], elements[[1]][2], sep='XXX')

        stub_list = c(to_mock)
        if ("stub_list" %in% names(attributes(get('::', original_env)))) {
            stub_list <- c(stub_list, attributes(get('::', original_env))[['stub_list']])
        }

        create_new_name <- create_create_new_name_function(stub_list, original_env)
        assign('::', create_new_name, original_env)
    } else {
        mock_func <- get(to_mock, original_env)
    }

    mock_env <- new.env(parent=environment(mock_func))

    expect_call_equal <- function(call_list)
    {
        if (length(names(expected_call_list)) != 0) {
            call_list = call_list[names(expected_call_list)]
        } else {
            call_list = tail(call_list, -1)
        }

        if (length(names(call_list)) != 0) {
            call_list = lapply(names(call_list),
                            function(x) eval(parse(text=x), parent.frame(3)))
        } else {
            call_list = lapply(call_list,
                            function(x) eval(parse(text=x), parent.frame(4)))
        }
        names(call_list) = names(expected_call_list)
        testthat::expect_equal(call_list, expected_call_list)
    } # expect_call_equal

    assign('expect_call_equal', expect_call_equal, mock_env)

    function_source <- get_function_source(mock_func)
    function_source <- add_first_statement(function_source, 'expect_call_equal(as.list(match.call()))')

    mocked_function <- eval(parse(text=function_source), mock_env)
    assign(to_mock, mocked_function, original_env)

    environment(func) <- original_env
    assign(func_name, func, parent.frame())
}
