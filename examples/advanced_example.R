# ===============================================================================
# BCALLPACKAGE: ADVANCED USAGE EXAMPLE
# ===============================================================================
# Advanced features including manual pivot selection and sensitivity analysis
# ===============================================================================

library(BCallPackage)

# ===============================================================================
# EXAMPLE 1: MANUAL PIVOT SELECTION
# ===============================================================================

cat("=== EXAMPLE 1: MANUAL PIVOT SELECTION ===\n")

# List available legislators by cluster to choose pivot
cat("Available legislators for pivot selection:\n")
legislators_by_cluster <- list_legislators_by_cluster(
  legislators_file = "data/legislators.csv",
  votes_file = "data/votes.csv",
  threshold = 0.3
)

# Get a legislator from the 'right' cluster for pivot
right_legislators <- legislators_by_cluster[legislators_by_cluster$cluster == "right", ]
if (nrow(right_legislators) > 0) {
  manual_pivot_name <- right_legislators$legislator[1]

  cat(sprintf("\nUsing manual pivot: %s\n", manual_pivot_name))

  # Run analysis with manual pivot
  result_manual <- run_bcall_analysis(
    legislators_file = "data/legislators.csv",
    votes_file = "data/votes.csv",
    manual_pivot = manual_pivot_name,
    threshold = 0.3,
    verbose = TRUE
  )

  cat("Manual pivot analysis completed!\n")
} else {
  cat("No legislators found in 'right' cluster for manual pivot\n")
}

# ===============================================================================
# EXAMPLE 2: SENSITIVITY ANALYSIS
# ===============================================================================

cat("\n=== EXAMPLE 2: SENSITIVITY ANALYSIS ===\n")

# Test different participation thresholds
thresholds <- c(0.1, 0.3, 0.5, 0.7)
sensitivity_results <- list()

cat("Running sensitivity analysis with different thresholds:\n")

for (i in 1:length(thresholds)) {
  thresh <- thresholds[i]

  cat(sprintf("  Testing threshold: %.1f\n", thresh))

  tryCatch({
    result <- run_bcall_analysis(
      legislators_file = "data/legislators.csv",
      votes_file = "data/votes.csv",
      threshold = thresh,
      verbose = FALSE
    )

    sensitivity_results[[sprintf("threshold_%.1f", thresh)]] <- result

    cat(sprintf("    ✓ Success: %d legislators analyzed\n",
               nrow(result$results)))

  }, error = function(e) {
    cat(sprintf("    ✗ Failed: %s\n", e$message))
  })
}

# Compare results across thresholds
if (length(sensitivity_results) > 1) {
  cat("\nSensitivity Analysis Summary:\n")
  cat("Threshold | Legislators | Mean d1 | Mean d2 | SD d1 | SD d2\n")
  cat("----------|-------------|---------|---------|-------|-------\n")

  for (name in names(sensitivity_results)) {
    res <- sensitivity_results[[name]]$results
    thresh <- sensitivity_results[[name]]$metadata$threshold

    cat(sprintf("   %.1f    |     %3d     |  %5.3f  |  %5.3f  | %5.3f | %5.3f\n",
               thresh,
               nrow(res),
               mean(res$d1, na.rm = TRUE),
               mean(res$d2, na.rm = TRUE),
               sd(res$d1, na.rm = TRUE),
               sd(res$d2, na.rm = TRUE)))
  }
}

# ===============================================================================
# EXAMPLE 3: COMPARISON PLOTS
# ===============================================================================

cat("\n=== EXAMPLE 3: COMPARISON PLOTS ===\n")

if (length(sensitivity_results) >= 2) {
  # Create comparison plots for different thresholds
  library(ggplot2)

  # Combine results for comparison
  combined_data <- data.frame()

  for (name in names(sensitivity_results)[1:2]) {  # Compare first two
    res_data <- sensitivity_results[[name]]$results
    res_data$threshold <- sensitivity_results[[name]]$metadata$threshold
    res_data$analysis <- name
    combined_data <- rbind(combined_data, res_data)
  }

  # Create comparison plot
  comparison_plot <- ggplot(combined_data, aes(x = d1, y = d2, color = factor(threshold))) +
    geom_point(alpha = 0.7, size = 2) +
    facet_wrap(~ paste("Threshold:", threshold)) +
    labs(
      title = "B-Call Analysis: Threshold Sensitivity Comparison",
      x = "d1 (Ideological Position)",
      y = "d2 (Political Cohesion)",
      color = "Threshold"
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")

  print(comparison_plot)

  cat("Comparison plot created!\n")
}

# ===============================================================================
# EXAMPLE 4: DETAILED ANALYSIS OF EXTREME POSITIONS
# ===============================================================================

cat("\n=== EXAMPLE 4: EXTREME POSITIONS ANALYSIS ===\n")

if (exists("result_manual")) {
  result <- result_manual
} else {
  # Fallback to automatic analysis
  result <- run_bcall_analysis(
    legislators_file = "data/legislators.csv",
    votes_file = "data/votes.csv",
    threshold = 0.3,
    verbose = FALSE
  )
}

results_df <- result$results

# Find extreme positions
most_liberal <- results_df[which.min(results_df$d1), ]
most_conservative <- results_df[which.max(results_df$d1), ]
most_cohesive <- results_df[which.min(results_df$d2), ]
least_cohesive <- results_df[which.max(results_df$d2), ]

cat("EXTREME POSITIONS ANALYSIS:\n")
cat("==========================\n")

cat("Most Liberal Legislator:\n")
cat(sprintf("  %s (d1=%.3f, d2=%.3f, cluster=%s)\n",
           most_liberal$legislator, most_liberal$d1, most_liberal$d2, most_liberal$cluster))

cat("Most Conservative Legislator:\n")
cat(sprintf("  %s (d1=%.3f, d2=%.3f, cluster=%s)\n",
           most_conservative$legislator, most_conservative$d1, most_conservative$d2, most_conservative$cluster))

cat("Most Cohesive Legislator:\n")
cat(sprintf("  %s (d1=%.3f, d2=%.3f, cluster=%s)\n",
           most_cohesive$legislator, most_cohesive$d1, most_cohesive$d2, most_cohesive$cluster))

cat("Least Cohesive Legislator:\n")
cat(sprintf("  %s (d1=%.3f, d2=%.3f, cluster=%s)\n",
           least_cohesive$legislator, least_cohesive$d1, least_cohesive$d2, least_cohesive$cluster))

# ===============================================================================
# EXAMPLE 5: EXPORT ALL ANALYSES
# ===============================================================================

cat("\n=== EXAMPLE 5: EXPORT ALL ANALYSES ===\n")

# Create output directory
if (!dir.exists("output")) {
  dir.create("output")
}

# Export main analysis
export_bcall_analysis(result,
                     output_dir = "output",
                     prefix = "advanced_main")

# Export sensitivity analyses
if (length(sensitivity_results) > 0) {
  for (name in names(sensitivity_results)) {
    export_bcall_analysis(sensitivity_results[[name]],
                         output_dir = "output",
                         prefix = paste("sensitivity", name, sep = "_"))
  }
}

cat("All analyses exported to 'output/' directory\n")

cat("\n=== ADVANCED ANALYSIS COMPLETE ===\n")