# bcall

B-Call analysis for legislative voting data in R.

## Installation

```r
devtools::install_github("Alcatruz/bcall")
library(bcall)
```

## Usage Examples

### Path 1: Excel Files with Party Info → B-Call

```r
# Load Chilean sample data (Excel with party info)
rollcall_data <- load_chile_sample()
results <- run_bcall_from_rollcall(rollcall_data, pivot = "Legislador_Derecha")

# Visualize with party information
plot_bcall_analysis_interactive(results, color_by = "party")
```

### Path 2a: CSV Rollcall with Party Info → B-Call

```r
# Load rollcall matrix with party information
rollcall_data <- load_rollcall_direct("rollcall.csv", "parties.csv")
results <- run_bcall_from_rollcall(rollcall_data, pivot = "Legislator_Name")

# Visualize with party colors
plot_bcall_analysis_interactive(results, color_by = "party")
```

### Path 2b: CSV Rollcall → Automatic Clustering → B-Call

```r
# Generate automatic clustering from CSV rollcall only
rollcall_with_clusters <- generate_clustering_from_rollcall_direct("rollcall.csv",
                                                                  distance_method = 1,
                                                                  pivot = "Legislator_Name")
results <- run_bcall_with_auto_clusters(rollcall_with_clusters)

# Visualize with automatic clustering
plot_bcall_analysis_interactive(results)
```

## Available Sample Data

The package includes sample datasets:

**Chilean Data (Excel with party info):**
- `legist_chile.xlsx` / `votes_chile.xlsx` - Chilean legislative data with party information

**USA Data (CSV for auto-clustering):**
- `USA-House-2021-rollcall.csv` - US House rollcall data 2021
- `USA-House-2022-rollcall.csv` - US House rollcall data 2022

**CSV Structure:**
- Rollcall: Legislators as rows, votes as columns, values: 1 (Yes), -1 (No), 0 (Abstention), NA (Absent)
- Party CSV: Two columns: `legislator` (matching rollcall row names), `party`

## Installation and Testing

After installation, test with the sample data:

```r
# Quick test
library(bcall)
legist_file <- system.file("extdata", "legist_chile.xlsx", package = "bcall")
votes_file <- system.file("extdata", "votes_chile.xlsx", package = "bcall")
rollcall_data <- excel_to_rollcall(legist_file, votes_file)
```

## License

MIT