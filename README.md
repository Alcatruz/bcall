# bcall

B-Call analysis for legislative voting data in R.

## Installation

```r
# Install dependencies
install.packages(c("R6", "dplyr", "ggplot2", "plotly", "readxl", "tidyr"))

# Install bcall package
setwd("path/to/B-Call")
devtools::install("bcall")
library(bcall)
```

## Usage Examples

### Path 1: Excel Files with Party Info → B-Call

```r
# CAMINO 1: EXCEL → ROLLCALL (con party info) → B-CALL
rollcall_data1 <- excel_to_rollcall("data/legist_chile.xlsx", "data/votes_chile.xlsx")
results1 <- run_bcall_from_rollcall(rollcall_data1, pivot = "Legislador_Derecha")

# VISUALIZAR con party info del Excel
plot_bcall_analysis_interactive(results1, color_by = "party")
```

### Path 2: CSV Rollcall → Automatic Clustering → B-Call

```r
# CAMINO 2: CSV → CLUSTERING AUTOMÁTICO → B-CALL
rollcall_data <- read_excel("CHL-DIP-2019-rollcall.xlsx")

legislators_names <- rollcall_data$legislators
rollcall_matrix_temp <- as.data.frame(rollcall_data[, -1])
rownames(rollcall_matrix_temp) <- legislators_names
write.csv(rollcall_matrix_temp, "temp_rollcall.csv")

rollcall_with_clusters2 <- generate_clustering_from_rollcall_direct("temp_rollcall.csv",
                                                                   distance_method = 1,
                                                                   pivot = "Alessandri, Jorge")
results2 <- run_bcall_with_auto_clusters(rollcall_with_clusters2)

# VISUALIZAR con cluster automático
plot_bcall_analysis_interactive(results2)

# OPCIONAL: Correlación con NOMINATE (solo si se quiere comparar)
nominate_data <- read_excel("CHL-DIP-2019-nominate.xlsx")
cat("Correlación con clustering automático:",
    cor(results2$results$d1, nominate_data$x1, use = "complete.obs"), "\n")

# Limpiar
file.remove("temp_rollcall.csv")
```

## License

MIT