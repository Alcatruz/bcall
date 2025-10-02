# BCallPackage: B-Call Analysis for Legislative Voting Data

R package for B-Call analysis (Integrating Ideological Position and Political Cohesion) for legislative voting data using **Excel and CSV files**.

[![R](https://img.shields.io/badge/R-%3E%3D3.5.0-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📋 Overview

BCallPackage implements the B-Call methodology for analyzing legislative voting data. It processes **Excel and CSV files** containing legislator information and voting records to produce:

- **d1**: Ideological position (Liberal ← → Conservative)
- **d2**: Political cohesion (More cohesive ← → Less cohesive)

## 🏗️ Package Structure

```
BCallPackage/
├── R/                  # R functions and classes
│   ├── bcall_classes.R                # Core BCall and Clustering classes
│   └── bcall_analysis_functions.R     # Main analysis functions
├── data/               # Sample data files
│   ├── legist_chile.xlsx             # Chilean legislators (Excel)
│   ├── votes_chile.xlsx              # Chilean votes (Excel)
│   ├── legislators.csv               # Legislator information (CSV)
│   └── votes.csv                     # Voting records (CSV)
├── man/                # Documentation files
├── examples/           # Usage examples
├── DESCRIPTION         # Package metadata
├── NAMESPACE          # Exported functions
└── README.md          # This file
```

## 📦 Installation

### From GitHub (Recommended)

```r
# Install devtools if not already installed
install.packages("devtools")
# install remotes if devtools is not preferred
# install.packages("remotes")
# Install BCallPackage from GitHub
devtools::install_github("Alcatruz/BCallPackage")
```


## 🚀 Quick Start

### Option A: Excel Files (Recommended for New Users)

```r
library(BCallPackage)

# Complete workflow from Excel files
results <- bcall_excel_workflow(
  legislators_file = "data/legist_chile.xlsx",
  votes_file = "data/votes_chile.xlsx",
  save_rollcall = TRUE,
  output_dir = "my_results"
)

# View results
print(results$summary)
plot_bcall_analysis(results$bcall_results)
```

### Option B: CSV Files (Advanced Users)

### 1. Load the Package

```r
library(BCallPackage)
```

### 2. Excel Data Format

For Excel files, you need two .xlsx files with these structures:

#### **legist_chile.xlsx** format:
- `nm_y_apellidos`: Full name of legislator
- `partido_alias`: Party abbreviation
- `party`: Political orientation ("left" or "right")

#### **votes_chile.xlsx** format:
- `nm_y_apellidos`: Legislator name (must match legislators file)
- `votacion_id`: Unique voting session ID
- `voto`: Vote value ("Sí"/"Si"/"YES"/"1" = yes, "No"/"NO"/"0" = no)

### 3. CSV Data Format (Alternative)

You need two CSV files:

#### **legislators.csv** format:
```csv
nm_y_apellidos,partido_alias,party
Juan_Pérez_González,DC,left
María_García_López,UDI,right
Carlos_Silva_Martín,PS,left
```

Required columns:
- `nm_y_apellidos`: Legislator full names
- `partido_alias`: Party abbreviation (optional)
- `party`: Binary clustering ("left"/"right")

#### **votes.csv** format:
```csv
nm_y_apellidos,votacion_id,voto
Juan_Pérez_González,1,1
Juan_Pérez_González,2,-1
María_García_López,1,-1
María_García_López,2,1
```

Required columns:
- `nm_y_apellidos`: Legislator names (must match legislators.csv)
- `votacion_id`: Unique vote identifier
- `voto`: Vote value (1 = "Afirmativo", -1 = "En Contra", NA = abstention)

### 3. Run Complete Analysis

```r
# Automatic analysis with CSV files
result <- run_bcall_analysis(
  legislators_file = "data/legislators.csv",
  votes_file = "data/votes.csv",
  threshold = 0.3,        # Minimum 30% participation
  auto_pivot = TRUE,      # Auto-select pivot from 'right' cluster
  verbose = TRUE
)
```

### 4. Visualize Results

```r
# Static plot
plot_bcall_analysis(result)

# Interactive plot with hover labels
plot_bcall_analysis_interactive(result)

# Plot colored by party
plot_bcall_analysis(result, color_by = "partido_alias")
```

### 5. Export Results

```r
# Export all results to CSV and PNG
export_bcall_analysis(result,
                     output_dir = "output",
                     prefix = "my_analysis")
```

## 🔧 Advanced Usage

### Manual Pivot Selection

```r
# List available legislators by cluster
list_legislators_by_cluster()

# Use specific pivot from 'right' cluster
result <- run_bcall_analysis(
  manual_pivot = "SPECIFIC_RIGHT_LEGISLATOR_NAME",
  threshold = 0.3
)
```

### Sensitivity Analysis

```r
# Compare different participation thresholds
thresholds <- c(0.1, 0.3, 0.5, 0.7)
results <- list()

for (thresh in thresholds) {
  results[[paste0("t_", thresh)]] <- run_bcall_analysis(
    threshold = thresh,
    verbose = FALSE
  )
}
```

### Statistical Summary

```r
# Complete analysis summary
summarize_bcall_analysis(result)
```

## 📊 Understanding Results

### Result Structure

The `run_bcall_analysis()` function returns a list with:

```r
result$results          # Data frame with d1, d2 coordinates and metadata
result$metadata         # Analysis parameters and statistics
result$bcall_object     # Original BCall object for advanced analysis
result$raw_data         # Original rollcall and clustering data
```

### Coordinate Interpretation

- **d1 (Ideological Position)**:
  - Negative values: More liberal positions
  - Positive values: More conservative positions
  - Range typically: -1 to +1

- **d2 (Political Cohesion)**:
  - Lower values: More cohesive voting behavior
  - Higher values: Less cohesive (more volatile) behavior
  - Range typically: 0 to +1

### Pivot Selection Importance

⚠️ **Critical**: For correct d1 orientation (liberal ← → conservative), always use a pivot from the **"right" cluster**. Using a "left" cluster pivot will invert the d1 dimension.

The package automatically:
- Selects pivots from "right" cluster when `auto_pivot = TRUE`
- Warns when manual pivots are from "left" cluster
- Chooses the highest-participation legislator from "right" cluster

## 📝 Example Workflow

```r
library(BCallPackage)

# 1. Load and analyze data
result <- run_bcall_analysis(
  legislators_file = "data/legislators.csv",
  votes_file = "data/votes.csv",
  threshold = 0.3,
  verbose = TRUE
)

# 2. View results summary
print(result$metadata)
head(result$results)

# 3. Create visualizations
main_plot <- plot_bcall_analysis(result)
interactive_plot <- plot_bcall_analysis_interactive(result)

# 4. Statistical analysis
summarize_bcall_analysis(result)

# 5. Export everything
exported_files <- export_bcall_analysis(result,
                                        output_dir = "results",
                                        prefix = "legislative_analysis")
```

## 🔧 Dependencies

- **R** (>= 3.5.0)
- **R6** (>= 2.4.0) - Object-oriented programming
- **dplyr** (>= 1.0.0) - Data manipulation
- **ggplot2** (>= 3.3.0) - Static plotting
- **plotly** (>= 4.9.0) - Interactive plotting

## 📋 CSV Data Requirements

### Legislators File
- **Required columns**: `nm_y_apellidos`, `party`
- **Optional columns**: `partido_alias` (for party-colored plots)
- **party values**: Must be exactly 2 unique values ("left", "right" recommended)

### Votes File
- **Required columns**: `nm_y_apellidos`, `votacion_id`, `voto`
- **Vote values**: 1, -1, or NA (missing)
- **legislator names**: Must match exactly with legislators file

## 🚨 Common Issues

### Error: "clustering must have only two unique values"
- Verify `party` column has exactly 2 unique values
- Check for typos in party assignments

### Error: "pivot must be an element of rollcall's index"
- Ensure pivot legislator name exists in votes data
- Check for exact name matching (including spaces, accents)

### Warning: "Manual pivot from 'left' cluster"
- Use a legislator from 'right' cluster for correct d1 orientation
- Or use `auto_pivot = TRUE` for automatic selection

### Files not found
- Verify CSV file paths are correct
- Ensure files are in specified directory

## 📚 Algorithm Details

The package implements the B-Call algorithm exactly as described in the original paper:

1. **Data Processing**: Converts CSV files to rollcall matrix format
2. **Participation Filtering**: Removes legislators below threshold
3. **Standardization**: Normalizes votes by overall mean and standard deviation
4. **Orientation**: Uses pivot legislator to determine ideological direction
5. **Calculation**:
   - d1 = mean of standardized votes (ideological position)
   - d2 = standard deviation of standardized votes (political cohesion)

## 📄 Citation

If you use this package in your research, please cite:

```
[Your B-Call paper citation here]
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Bug Reports & Feature Requests

Please report issues on [GitHub Issues](https://github.com/yourusername/BCallPackage/issues).

---

**Made with ❤️ for political science research**