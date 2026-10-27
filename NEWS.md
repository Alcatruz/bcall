# bcall 1.0.0

* First CRAN submission.
* `bcall_auto()` warns when it picks the pivot itself, because the sign of
  d1 then depends on the order of the rows.
* `bcall()` works with a single vote, and `metadata$n_legislators_original`
  counts the rows of `rollcall`.
* `plot_bcall_analysis()` no longer uses the deprecated `aes_string()`.
* dplyr is no longer a dependency, and plotly moved to Suggests: only
  `plot_bcall_analysis_interactive()` needs it.
