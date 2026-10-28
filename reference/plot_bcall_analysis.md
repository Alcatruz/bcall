# Plot B-Call Analysis Results

Creates static ggplot2 visualization of B-Call results

## Usage

``` r
plot_bcall_analysis(
  bcall_results,
  title = "B-Call Analysis: Legislative Voting",
  color_by = "auto",
  show_names = FALSE,
  alpha = 0.7,
  size = 2.5
)
```

## Arguments

- bcall_results:

  List, output from bcall_auto() or bcall()

- title:

  Character, plot title

- color_by:

  Character, variable to color by ("auto" for automatic detection)

- show_names:

  Logical, whether to show legislator names

- alpha:

  Numeric, point transparency (0-1)

- size:

  Numeric, point size

## Value

ggplot2 object

## Examples

``` r
# Create sample data and run analysis
rollcall <- data.frame(
  vote1 = c(1, -1, 1, -1, 1),
  vote2 = c(1, -1, 1, -1, 1),
  vote3 = c(-1, 1, -1, 1, -1),
  row.names = paste0("Leg_", LETTERS[1:5])
)

results <- bcall_auto(rollcall, pivot = "Leg_B", verbose = FALSE)

# Create static plot
plot_bcall_analysis(results)


# With legislator names
plot_bcall_analysis(results, show_names = TRUE)

```
