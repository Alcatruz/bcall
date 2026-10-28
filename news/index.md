# Changelog

## bcall 1.0.0

- First CRAN submission.
- [`bcall_auto()`](https://alcatruz.github.io/bcall/reference/bcall_auto.md)
  warns when it picks the pivot itself, because the sign of d1 then
  depends on the order of the rows.
- [`bcall()`](https://alcatruz.github.io/bcall/reference/bcall.md) works
  with a single vote, and `metadata$n_legislators_original` counts the
  rows of `rollcall`.
- Progress messages go through
  [`message()`](https://rdrr.io/r/base/message.html), so
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) silences
  them, and the results have a short
  [`print()`](https://rdrr.io/r/base/print.html) method.
- [`plot_bcall_analysis()`](https://alcatruz.github.io/bcall/reference/plot_bcall_analysis.md)
  no longer uses the deprecated `aes_string()`.
- dplyr is no longer a dependency, and plotly moved to Suggests: only
  [`plot_bcall_analysis_interactive()`](https://alcatruz.github.io/bcall/reference/plot_bcall_analysis_interactive.md)
  needs it.
