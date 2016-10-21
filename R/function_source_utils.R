
#' Returns the pure R source code for a given function.
#'
#' @param func function for which to retreive the source code.
#' @return \code{func}'s source code as a single \code{character} value.
#'
#' @export
#' @importFrom utils capture.output
#'
get_function_source <- function(func)
{
    output <- capture.output(print(func))

    # drops environment and namespace information
    output <- Filter(function(x) !startsWith(trimws(x), '<'), output)

    output <- add_brackets(output)
    output <- sapply(output, trimws)
    paste(output, '', sep = '\n', collapse = '')
}


add_first_statement <- function(function_source, statement)
{
    sub('\\{', paste('{\n', statement, '\n'), function_source)
}


add_brackets <- function(output)
{
    if (length(output) == 1) {
        last <- max(gregexpr(')', output[1])[[1]])
        output <- c(substr(output, 1, last), '{', substring(output, last + 1), '}')
    }
    return(output)
}
