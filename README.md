# mockery
A mocking library for R.

### Installation

From the R shell:

```.R
> # If you don't have devtools installed yet:
> install.packages('devtools')
>
> # Then:
> library('devtools')
> devtools::install_github('n-s-f/mockery')
```

### Testing

Mockery is essentially a plugin for [testthat](github.com/hadley/testthat).  Please read testthat's excellent documentation for getting set up with testing.

Mockery provides the capacity for stubbing out functions and for verifying function calls during testing. Additional functionality wil be forthcoming.  Please note any bugs or feature requests in github issues.

#### Stubbing

Mockery's `stub` function will let you stub out a function with another function or simply a return value.  Note that if you choose to replace the function with another function, the signatures of the two functions should be compatible.

You can stub out namespaced calls by just passing in a string like 'namespace_name::function_name' as the function to stub.

The stubbing will expire once the test function exits.

**stub**(func, to_stub, return_value)
- func - The function you plan to call, and for which you want to stub out another function.
- to_stub - A string that is the name of the function you want to stub out.
- return_value - If this is a function, it replaces the function you are stubbing out. Otherwise, the function you are stubbing out will always return this value.

##### Examples

In this test, we see that a non name-spaced function is appropriately replaced with another function.

```.R
test_that('stubs function with function', {                                        
    # given                                                                        
    a = 10                                                                         
    f = function(x) x                                                              
    g = function(x) f(x) + a                                                       
  
    # before stubbing                                                              
    expect_equal(g(20), 30)                                                        
  
    # when                                                                         
    stub(g, 'f', function(...) 500)                                                
    
    # then                                                                         
    expect_equal(g(10), 510)                                                       
})   
```

In the next test, we see that a name-spaced function is appropriately replaced with a function that returns the return value.

```.R
test_that('stubs function from namespace', {                                       
    # given                                                                        
    f = function() mockery::get_function_source(function(x) x)                     
                                                                                   
    # before stubbing                                                              
    expect_equal(trimws(f()), 'function(x)\n{\nx\n}')                              
                                                                                   
    # when                                                                         
    stub(f, 'mockery::get_function_source', 10)                                    
                                                                                   
    # then                                                                         
    expect_equal(f(), 10)                                                          
})
```

#### Using mock objects

Sometimes it's not enough just to stub out the function of interest with another function. You may want to be able to make assertions about how the stubbed-out function was treated - how many times it was called, with which arguments, etc.

In such cases, you can stub out the function with mockery's mock objects.

```.R
test_that('stub works well with mock object', {
    # given
    f = function(x) x + 10
    g = function(x) f(x)

    mock_object = mock(100)
    stub(g, 'f', mock_object)

    # when
    result = g(5)

    # then
    expect_equal(result, 100)
})

f = function(x) x + 10
g = function(x) f(x)
test_that('mock object returns value', {
    mock_object = mock(1)
    stub(g, 'f', mock_object) 

    expect_equal(g('anything'), 1)
    expect_no_calls(mock_object, 1)
    expect_args(mock_object, 1, 'anything')
})

test_that('mock object multiple return values', {
    mock_object = mock(1, "a", sqrt(3))
    stub(g, 'f', mock_object) 

    expect_equal(g('anything'), 1)
    expect_equal(g('anything'), "a")
    expect_equal(g('anything'), sqrt(3))
})
                                   
test_that('mock object accessing values of arguments', {
    mock_object <- mock()
    mock_object(x = 1)
    mock_object(y = 2)

    expect_equal(length(mock_object), 2)
    args <- mock_args(mock_object)

    expect_equal(args[[1]], list(x = 1))
    expect_equal(args[[2]], list(y = 2))
})

test_that('mock object accessing call expressions', {
    mock_object <- mock()
    mock_object(x = 1)
    mock_object(y = 2)

    expect_equal(length(mock_object), 2)
    calls <- mock_calls(mock_object)

    expect_equal(calls[[1]], quote(mock_object(x = 1)))
    expect_equal(calls[[2]], quote(mock_object(y = 2)))
})
```

#### Verifying function calls

Sometimes you may want to make a assertions about function calls while still allowing the function to execute. In such cases, the mock objects above will not work.

Mockery's `expect_called` function works a little like one of `testthat`'s expecations, and allows you to verify that the function was called correctly. The difference is the this expectation has to be set _before_ the mock is called.

Note that unless the function was stubbed out as above, the function will still execute as before. If the function was stubbed out, the stub will behave correctly.  If the function is stubbed _after_ the expectation is set, the expectation will get overwritten.

**expect_called**(func, to_mock, expected_call_list)
- func - The function you plan to call, and within which you want to verify a call to another function.
- to_stub - A string that is the name of the function you want to verify a call to.
- expected_call_list - This is the list of parameters you expect to be present in the function call. It can be a list with or without names. If it is a list _with_ names, it can be a partial list, i.e. it doesn't need to include all the parameters. Only the included parameters will be checked.

##### Examples

In this function, we verify that two of the three named parameters are passed as expected.

```.R
test_that('expect called verifies with partial call list', {                    
    # given                                                                     
    g = function(y, z, x) y + z + x + 10                                        
    f = function(x) g(y=1, z=2, x=(x + 1))                                      
                                                                                
    # expect                                                                    
    expect_called(f, 'g', list(y=1, x=6))                              
                                                                                
    # when                                                                      
    f(5)                                                                        
})   
```

In the next function, we use an unnamed list to verify a call to a namespaced function that we've stubbed out.

```.R
test_that('expect called works with namespaced funtions', {                   
    # given                                                                     
    g = function(x, y) testthat::expect_equal(x, y)                             
                                                                                
    # expect  
    stub(g, 'testthat::expect_equal', NULL)
    expect_called(g, 'testthat::expect_equal', list(1, 1))             
                                                                                
    # when                                                                      
    g(1, 1)                                                                     
})                                                                              
```

