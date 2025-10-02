# bcall

B-Call analysis for legislative voting data in R.

## Installation

```r
# Install dependencies
install.packages(c("R6", "dplyr", "ggplot2", "plotly", "readxl", "tidyr"))

# Install bcall package from GitHub
devtools::install_github("Alcatruz/bcall")
library(bcall)
library(readxl)
```

## Usage Examples

### Path 1: Excel Files with Party Info → B-Call

```r
# Using sample data included with package
legist_file <- system.file("extdata", "legist_chile.xlsx", package = "bcall")
votes_file <- system.file("extdata", "votes_chile.xlsx", package = "bcall")

rollcall_data1 <- excel_to_rollcall(legist_file, votes_file)
results1 <- run_bcall_from_rollcall(rollcall_data1, pivot = "Legislador_Derecha")

# Visualize with party information from Excel
plot_bcall_analysis_interactive(results1, color_by = "party")
```

### Path 2: CSV Rollcall → Automatic Clustering → B-Call

```r
# Using sample data included with package
rollcall_file <- system.file("extdata", "CHL-DIP-2019-rollcall.xlsx", package = "bcall")
rollcall_data <- read_excel(rollcall_file)

legislators_names <- rollcall_data$legislators
rollcall_matrix_temp <- as.data.frame(rollcall_data[, -1])
rownames(rollcall_matrix_temp) <- legislators_names
write.csv(rollcall_matrix_temp, "temp_rollcall.csv")

rollcall_with_clusters2 <- generate_clustering_from_rollcall_direct("temp_rollcall.csv",
                                                                   distance_method = 1,
                                                                   pivot = "Alessandri, Jorge")
results2 <- run_bcall_with_auto_clusters(rollcall_with_clusters2)

# Visualize with automatic clustering
plot_bcall_analysis_interactive(results2)

# Optional: correlation with NOMINATE scores
nominate_file <- system.file("extdata", "CHL-DIP-2019-nominate.xlsx", package = "bcall")
nominate_data <- read_excel(nominate_file)
cat("Correlation with automatic clustering:",
    cor(results2$results$d1, nominate_data$x1, use = "complete.obs"), "\n")

# Clean up
file.remove("temp_rollcall.csv")
```

## Available Sample Data

The package includes sample datasets:

**Chilean Data:**
- `legist_chile.xlsx` / `votes_chile.xlsx` - Chilean legislative data with party information
- `CHL-DIP-2019-nominate.xlsx` / `CHL-DIP-2019-rollcall.xlsx` - Chilean NOMINATE scores and rollcall data

**USA Data:**
- `USA-House-2021-nominate.csv` / `USA-House-2021-rollcall.csv` - US House data
- `USA-House-2022-rollcall.csv` - Additional US rollcall data

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