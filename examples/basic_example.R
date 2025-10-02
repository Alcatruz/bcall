# ===============================================================================
# BCALLPACKAGE: BASIC USAGE EXAMPLE
# ===============================================================================
# Example script showing basic usage of BCallPackage with CSV data
# ===============================================================================

library(BCallPackage)

# ===============================================================================
# EXAMPLE 1: BASIC ANALYSIS
# ===============================================================================

cat("=== EXAMPLE 1: BASIC ANALYSIS ===\n")

# Run complete analysis with CSV files
result <- run_bcall_analysis(
  legislators_file = "data/legislators.csv",
  votes_file = "data/votes.csv",
  threshold = 0.3,        # Minimum 30% participation
  auto_pivot = TRUE,      # Auto-select pivot from 'right' cluster
  verbose = TRUE
)

# View result structure
cat("\nResult structure:\n")
print(names(result))

# View first rows of results
cat("\nFirst rows of results:\n")
print(head(result$results))

# View metadata
cat("\nAnalysis metadata:\n")
print(result$metadata)

# ===============================================================================
# EXAMPLE 2: VISUALIZATION
# ===============================================================================

cat("\n=== EXAMPLE 2: VISUALIZATION ===\n")

# Create main plot
main_plot <- plot_bcall_analysis(result)
print(main_plot)

# Plot colored by party (if available)
if ("partido_alias" %in% colnames(result$results)) {
  party_plot <- plot_bcall_analysis(result, color_by = "partido_alias")
  print(party_plot)
}

# Interactive plot with plotly
interactive_plot <- plot_bcall_analysis_interactive(result)
print(interactive_plot)

# ===============================================================================
# EXAMPLE 3: STATISTICAL SUMMARY
# ===============================================================================

cat("\n=== EXAMPLE 3: STATISTICAL SUMMARY ===\n")

# Generate complete summary
summarize_bcall_analysis(result)

# ===============================================================================
# EXAMPLE 4: EXPORT RESULTS
# ===============================================================================

cat("\n=== EXAMPLE 4: EXPORT RESULTS ===\n")

# Create output directory if needed
if (!dir.exists("output")) {
  dir.create("output")
}

# Export all results
exported_files <- export_bcall_analysis(result,
                                        output_dir = "output",
                                        prefix = "basic_example")

cat("Exported files:\n")
print(exported_files)

cat("\n=== BASIC ANALYSIS COMPLETE ===\n")