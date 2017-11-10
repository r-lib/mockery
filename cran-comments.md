## Test environments
* local ubuntu 16.04, R 3.2.3
* ubuntu 12.04 (on travis-ci), R 3.2.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

## Reverse dependencies

There are 17 reverse dependencies. I ran `devtools::revdep_check()` with the
current version, and found a few errors. I also ran `devtools::revdep_check()`
with the version currently on CRAN, and found exactly the same errors.

I don't know why there are any errors at all, but based on the above I conclude
that this release doesn't break anything that wasn't already broken.

In particular, the error list in both casses looks like this:

Checked AlphaVantageClient: 0 errors | 0 warnings | 0 notes
Checked AzureML           : 1 error  | 0 warnings | 0 notes
Checked checkpoint        : 0 errors | 0 warnings | 0 notes
Checked civis             : 1 error  | 0 warnings | 0 notes
Checked cli               : 2 errors | 0 warnings | 1 note 
Checked cranlike          : 0 errors | 0 warnings | 0 notes
Checked crayon            : 0 errors | 0 warnings | 0 notes
Checked debugme           : 1 error  | 0 warnings | 0 notes
Checked keyring           : 1 error  | 0 warnings | 0 notes
Checked prettycode        : 0 errors | 0 warnings | 0 notes
Checked rGoodData         : 0 errors | 0 warnings | 0 notes
Checked sankey            : 0 errors | 0 warnings | 0 notes
Checked secret            : 0 errors | 0 warnings | 0 notes
Checked sessioninfo       : 1 error  | 0 warnings | 0 notes
Checked subprocess        : 0 errors | 0 warnings | 0 notes
Checked tracer            : 0 errors | 0 warnings | 0 notes
Checked whoami            : 0 errors | 0 warnings | 0 notes

