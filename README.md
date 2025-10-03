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

## Citation

If you use this package, please cite:

> Toro-Maureira S, Reutter J, Valenzuela L, Alcatruz D and Valenzuela M (2025) **B-Call: integrating ideological position and voting cohesion in legislative behavior**. *Frontiers in Political Science* 7:1670089. [https://doi.org/10.3389/fpos.2025.1670089](https://doi.org/10.3389/fpos.2025.1670089)
>
> Article page: [Frontiers in Political Science](https://www.frontiersin.org/journals/political-science/articles/10.3389/fpos.2025.1670089/abstract)

### BibTeX
```bibtex
@article{ToroMaureira2025BCall,
  author  = {Toro-Maureira, Sergio and Reutter, Juan and Valenzuela, Lucas and Alcatruz, Daniel and Valenzuela, Macarena},
  title   = {B-Call: integrating ideological position and voting cohesion in legislative behavior},
  journal = {Frontiers in Political Science},
  year    = {2025},
  volume  = {7},
  pages   = {1670089},
  doi     = {10.3389/fpos.2025.1670089},
  url     = {https://www.frontiersin.org/journals/political-science/articles/10.3389/fpos.2025.1670089/abstract}
}
