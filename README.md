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

#### Verifying function calls

Mockery's `expect_called` function works like one of `testthat`'s expecations, and allows you to verify that the function was called correctly.

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

