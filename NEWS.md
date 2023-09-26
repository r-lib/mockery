# mockery 0.4.4

* Fixes for `R CMD check`

# mockery 0.4.3

* Hadley Wickham is now the maintainer.

* `stub()` now unlocks/relocks locked bindings as required (@sambrightman, #30).

# mockery 0.4.2

* The R6 package has been added to Suggests, as requested by CRAN.

* `stub()` now works if the function being stubbed contains assignment functions (@jimhester, #23).

# mockery 0.4.1

* Fix bug whereby functions that begin with `.` don't have things mocked out in
them.

# mockery 0.4.0

* Add support for stubbing depth greater than 1.

* Add support for nested R6 classes.

# mockery 0.3.2

This release addresses issues https://github.com/jfiksel/mockery/issues/17 and
https://github.com/jfiksel/mockery/issues/13

In particular, it is now possible to mock functions out of R6 methods that
contain other R6 objects. Additionally, it's also possible to specify the depth
of mocking.
