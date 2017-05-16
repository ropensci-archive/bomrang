### Summary

-   What does this package do? (explain in 50 words or less):
Automates retrieval and formatting of Australian Bureau of Meteorology (BOM) data in R

-   Paste the full DESCRIPTION file inside a code block below:

```
Package: bomrang
Type: Package
Title: Fetch Australian Government Bureau of Meteorology Data
Version: 0.0.1
Authors@R: c(person("Adam", "Sparks", role = c("aut", "cre"),
    email = "adamhsparks@gmail.com"),
    person("Keith", "Pembleton", role = "aut",
    email = "keith.pembleton@usq.edu.au"))
Description: Fetches Australian Government Bureau of Meteorology weather XML
    files and returns a tidy data frame of data.
URL: https://github.com/ToowoombaTrio/bomrang
BugReports: https://github.com/ToowoombaTrio/bomrang/issues
License: MIT + file LICENSE
Depends:
    R (>= 3.2.0)
Imports:
    curl,
    dplyr,
    foreign,
    lubridate,
    plyr,
    readr,
    reshape2,
    stringr,
    tibble,
    tidyr,
    xml2
Encoding: UTF-8
LazyData: true
Suggests: covr,
    testthat,
    knitr,
    rmarkdown
RoxygenNote: 6.0.1
NeedsCompilation: no
ByteCompile: TRUE
VignetteBuilder: knitr
```

-   URL for the package (the development repository, not a stylized html page):
https://github.com/ToowoombaTrio/bomrang

-   Which categories does the package fall under from our [package fit policies](https://github.com/ropensci/onboarding/blob/master/policies.md#package-fit)? (e.g., data retrieval, reproducibility. If you are unsure, we suggest you make a pre-submission inquiry.):

data retrieval

-   Who is the target audience?

R users interested in using BOM forecasts or ag bulletins

-   Are there other R packages that accomplish the same thing? If so, what is different about yours?

None that I'm aware of

### Requirements

Confirm each of the following by checking the box.  This package:

- [x] does not violate the Terms of Service of any service it interacts with.
- [x] has a CRAN and OSI accepted license.
- [x] contains a README with instructions for installing the development version.
- [x] includes documentation with examples for all functions.
- [x] contains a vignette with examples of its essential functions and uses.
- [x] has a test suite.
- [x] has continuous integration, including reporting of test coverage, using
services such as Travis CI, Coeveralls and/or CodeCov.

- [x] I agree to abide by [ROpenSci's Code of Conduct](https://github.com/ropensci/onboarding/blob/master/policies.md#code-of-conduct) during
the review process and in maintaining my package should it be accepted.

#### Publication options

- [x] Do you intend for this package to go on CRAN?
- [x] Do you wish to automatically submit to the [Journal of Open Source Software](http://joss.theoj.org/)? If so:
    - [x] The package contains a [`paper.md`](http://joss.theoj.org/about#paper_structure) with a high-level description in the package root or in `inst/`.
    - [x] The package is deposited in a long-term repository with the DOI: http://doi.org/10.5281/zenodo.580122
    - (*Do not submit your package separately to JOSS*)

### Detail

- [x] Does `R CMD check` (or `devtools::check()`) succeed?  Paste and describe any errors or warnings:

- [x] Does the package conform to [rOpenSci packaging guidelines](https://github.com/ropensci/packaging_guide)? Please describe any exceptions:

- Please indicate which category or categories from our [package fit policies](https://github.com/ropensci/onboarding/blob/master/policies.md#package-fit) this package falls under and why:

Data retrieval - BOM publishes forecasts and ag bulletins in XML formats. This package automates the retrieval and formatting into tidy data frames for use in R.

- If this is a resubmission following rejection, please explain the change in circumstances:

- If possible, please provide recommendations of reviewers - those with experience with similar packages and/or likely users of your package - and their GitHub user names:
