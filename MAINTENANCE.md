## Current state

Mockery is stable.

## Known outstanding issues

`stub()` when depth > 2 does not work, or does not work how people naively
expect. https://github.com/r-lib/mockery/issues/47,
https://github.com/r-lib/mockery/issues/46,
https://github.com/r-lib/mockery/issues/52,
https://github.com/r-lib/mockery/issues/54,
https://github.com/r-lib/mockery/issues/29

I am not entirely sure if this is a deficiency in the mockery design or just something that could be worked around in the implementation.

I haven't really had much trouble running into this in my packages, because I rarely try to stub something greater than the first depth.

I generally feel like when people are running into this they are trying to do unit tests on too big of a unit, and writing smaller tests is better practice anyway.
