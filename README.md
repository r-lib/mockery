# mockery
[![Travis-CI Build Status](https://travis-ci.org/n-s-f/mockery.svg?branch=master)](https://travis-ci.org/n-s-f/mockery)
[![Coverage Status](https://img.shields.io/codecov/c/github/n-s-f/mockery/master.svg)](https://codecov.io/github/n-s-f/mockery?branch=master)
[![CRAN version](http://www.r-pkg.org/badges/version/mockery)](https://cran.r-project.org/package=mockery)

A mocking library for R.

### Installation

To install the latest CRAN release:

```.R
> install.packages('mockery')
```

To install directly from the source code in this github repository:

```.R
> # If you don't have devtools installed yet:
> install.packages('devtools')
>
> # Then:
> library('devtools')
> devtools::install_github('n-s-f/mockery')
```

### Testing

Mockery provides the capacity for stubbing out functions and for verifying
function calls during testing.

#### Stubbing

Mockery's `stub` function will let you stub out a function with another
function or simply a return value.  Note that if you choose to replace the
function with another function, the signatures of the two functions should be
compatible.

##### Examples

```.R
g = function(y) y
f = function(x) g(x) + 1
test_that('demonstrate stubbing', {
    # replaces 'g' with a function that always returns 100
    # but only when called from f
    stub(f, 'g', 100)

    # this can also be written
    stub(f, 'g', function(...) 100)
    expect_equal(f(1), 101)
})
```

Stubbing works with classes of all descriptions and namespaced functions:

```.R
# this stubs the 'request_perform' function, but only
# for httr::get, and only when it is called from within this
# test function
stub(httr::GET, 'request_perform', 'some html')
        
# it is also possible to stub out a namespaced function call
stub(some_function, 'namespace::function', 'some return value')
```

This also works with R6 classes and methods.

Finally, it's possible to specify the depth of stubbing. This is useful if you
want to stub a function that isn't called directly by the function you call in
you test but is called by a function that function calls. 

In the example below, the function `g` is both called directly from `r`, which
we call from the test, and from `f`, which `r` calls. By specifying a depth of
2, we tell mockery to stub `g` in both places.

```.R
g = function(y) y
f = function(x) g(x) + 1
r = function(x) g(x) + f(x)
test_that('demonstrate stubbing', {
    stub(f, 'g', 100, depth=2)
    expect_equal(r(1), 201)
})
```

For more examples, please see the test code contained in this repository.

##### Comparison to with_mock

Mockery's `stub` function has similar functionality to testthat's `with_mock`.

There are several use cases in which mockery's `stub` function will work, but
testthat's `with_mock` will not.

First, unlike `with_mock`, it seamlessly allows for mocking out primitives.

Second, it is easy to stub out functions from base R packages with mockery's `stub`.
Because of how `with_mock` works, you can get into trouble if you mock such functions 
that the JIT compiler might try to use. These kinds of problems are avoided by `stub`'s
design. As of version 2.0.0 of testthat, it will be impossible to mock functions from
base R packages `with_mock`.

The functionality of `stub` is just slightly different than that of `with_mock`. Instead
of mocking out the object of interest for the duration of some code block, it mocks it
out only when it is called from a specified function.

#### Mocking

Mock objects allow you to specify the behavior of the function you've stubbed
out while also verifying how that function was used. 

```.R
g = function(y) y
f = function(x) g(x) + 1
test_that('demonstrate mock object usage', {
    # mocks can specify behavior
    mock = mock(100)
    stub(f, 'g', mock)
    result = g(5)
    expect_equal(result, 101)

    # and allow you to make assertions on the mock was treated
    expect_called(mock, 1)
    expect_args(mock, 5)
})
```

You can also specify multiple return values

```.R 
mock = mock(1, "a", sqrt(3))
```

and access the arguments with which it was called.

```.R
mock <- mock()
mock(x = 1)
mock(y = 2)

expect_equal(length(mock), 2)
args <- mock_args(mock)

expect_equal(args[[1]], list(x = 1))
expect_equal(args[[2]], list(y = 2))
```

---

Please report bugs and feature requests through github issues.
