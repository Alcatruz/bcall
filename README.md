# bcall

B-Call analysis for legislative voting data in R.

## Installation

```r
# Install bcall package from GitHub
devtools::install_github("Alcatruz/bcall")
library(bcall)
```

## Usage Examples

### Path 1: Excel Files with Party Info → B-Call

```r
# Load Chilean sample data paths
excel_paths <- load_sample_excel_paths()

rollcall_data <- excel_to_rollcall(excel_paths$legist_file, excel_paths$votes_file)
results <- run_bcall_from_rollcall(rollcall_data, pivot = "Legislador_Derecha")

# Visualize with party information from Excel
plot_bcall_analysis_interactive(results, color_by = "party")
```

### Path 2: CSV Rollcall → Automatic Clustering → B-Call

```r
# Using sample USA rollcall data (CSV format)
usa_rollcall_file <- system.file("extdata", "USA-House-2021-rollcall.csv", package = "bcall")

# Generate automatic clustering from CSV
rollcall_with_clusters <- generate_clustering_from_rollcall_direct(usa_rollcall_file,
                                                                  distance_method = 1,
                                                                  pivot = "Kast_Rist_Jose_Antonio")
results <- run_bcall_with_auto_clusters(rollcall_with_clusters)

# Visualize with automatic clustering
plot_bcall_analysis_interactive(results)

# Check results summary
summary(results$results$d1)

# Optional: Load and compare with NOMINATE scores
nominate_file <- system.file("extdata", "USA-House-2021-nominate.csv", package = "bcall")
nominate_data <- read.csv(nominate_file)
cat("Correlation with NOMINATE:",
    cor(results$results$d1, nominate_data$coord1D, use = "complete.obs"), "\n")
```

### Alternative: Load data as objects (no temp files)

```r
# Load data directly as R objects
rollcall_matrix <- load_sample_rollcall("usa_2021")

# Then proceed with clustering...
```

## Available Sample Data

The package includes sample datasets:

**Chilean Data (Excel with party info):**
- `legist_chile.xlsx` / `votes_chile.xlsx` - Chilean legislative data with party information

**USA Data (CSV for auto-clustering):**
- `USA-House-2021-nominate.csv` / `USA-House-2021-rollcall.csv` - US House data 2021
- `USA-House-2022-rollcall.csv` - US House rollcall data 2022

**CSV Structure:** Legislators as rows, votes as columns, values: 1 (Yes), -1 (No), 0 (Abstention), NA (Absent)

Use `system.file("extdata", "filename", package = "bcall")` to access any included data file.

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