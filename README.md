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

For more examples, please see the test code contained in this repository.

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
