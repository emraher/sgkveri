# Repository Guidelines

## Project Structure & Module Organization
`sgkveri` follows a standard R package layout. Core client functions for hitting the SGK API live in `R/api.R`, `R/catalog.R`, and supporting helpers in `R/helpers.R`, `R/utils-*.R`, and `R/sgkveri.R`. Generated documentation resides in `man/`; edit the matching `R/` files and run roxygen rather than touching `.Rd` files. Tests live under `tests/testthat/` with HTTP fixtures in `_snaps` and `setup-mocks.R`. Public articles belong in `vignettes/`, while CLI assets and manual pages stay in `man/`. Use `README.Rmd` as the source for `README.md`.

## Build, Test, and Development Commands
- `R -q -e "pak::pak()"` installs the declared dependencies using binary packages when possible.
- `R -q -e "devtools::load_all()"` reloads the package for iterative development inside an interactive session.
- `R -q -e "devtools::document(); devtools::build()"` refreshes roxygen outputs and produces a tarball in `..`.
- `R CMD check --as-cran` or `R -q -e "devtools::check()"` runs the canonical package checks, including vignettes.
- `R -q -e "testthat::test_local()"` executes the full test suite; add `filter=\"api\"` when narrowing scope.

## Coding Style & Naming Conventions
Stick to tidyverse style already in the repo: 2-space indents, `<-` for assignment, and snake_case for objects. Exported functions keep the `sgk_*` or `sgk_get_*` prefix for discoverability; internal helpers can be suffixed with `_impl`. Keep arguments explicit (no `...` unless strictly needed) and prefer pipes for data verbs. All exported functions need roxygen blocks with `@examples` that query lightweight indicators. Avoid editing `NAMESPACE` manually—use `devtools::document()`.

## Testing Guidelines
Write `test_that()` blocks inside focused files such as `tests/testthat/test-api.R`. Mock HTTP calls with the helpers wired in `tests/testthat/setup-mocks.R` so CI never hits the live SGK service. Snapshot expected payloads under `tests/testthat/_snaps/<topic>.md` and regenerate them via `testthat::snapshot_accept()` only after verifying differences. For numeric coercion or parsing logic, add both success and failure cases and check attribute types. Aim to cover every new branch before submitting a PR; use `R -q -e "covr::report()"` locally if you need coverage confirmation.

## Commit & Pull Request Guidelines
Write commits in the format `area: imperative summary` (e.g., `api: cache yearly indicator lists`). Keep subjects under ~72 characters and explain motivation plus key decisions in the body. Reference GitHub issues using `Fixes #ID` when applicable. PRs should summarize the user-facing change, enumerate testing performed, and include screenshots or console snippets when docs or printed output change. Run `devtools::check()` before requesting review and mention any failing checks together with justification.
