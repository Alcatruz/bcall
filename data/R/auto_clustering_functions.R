# ===============================================================================
# FUNCIONES AUTOMÁTICAS PARA CLUSTERING + B-CALL
# ===============================================================================

#' Automatic clustering from rollcall data
#'
#' @description
#' Performs automatic clustering on rollcall data using the Clustering class.
#' This function wraps the Clustering class to provide a simple interface.
#'
#' @param rollcall_data Output from excel_to_rollcall() function
#' @param distance_method Integer, distance metric (1 = Manhattan, 2 = Euclidean)
#' @param pivot Character, pivot legislator name (NULL for automatic selection)
#' @param verbose Logical, whether to print progress messages
#'
#' @return List containing clustering results and metadata
#'
#' @examples
#' \dontrun{
#' rollcall_data <- excel_to_rollcall("legis.xlsx", "votos.xlsx")
#' clustering_result <- auto_clustering_from_rollcall(rollcall_data)
#' }
#'
#' @export
auto_clustering_from_rollcall <- function(rollcall_data, distance_method = 1, pivot = NULL, verbose = TRUE) {

  if (!inherits(rollcall_data, "list") ||
      !all(c("rollcall_matrix") %in% names(rollcall_data))) {
    stop("rollcall_data debe ser el resultado de excel_to_rollcall()")
  }

  if (verbose) cat("=== CLUSTERING AUTOMÁTICO DESDE ROLLCALL ===\n")

  rollcall_matrix <- rollcall_data$rollcall_matrix

  if (verbose) {
    cat("   - Matriz rollcall:", nrow(rollcall_matrix), "legisladores x", ncol(rollcall_matrix), "votaciones\n")
    distance_name <- if(distance_method == 1) "Manhattan" else if(distance_method == 2) "Euclidiana" else "Desconocida"
    cat("   - Método de distancia:", distance_name, "(N =", distance_method, ")\n")
  }

  # Selección automática de pivot si no se especifica
  if (is.null(pivot)) {
    pivot <- rownames(rollcall_matrix)[1]
    if (verbose) cat("   - Pivot seleccionado automáticamente:", pivot, "\n")
  } else {
    if (verbose) cat("   - Pivot especificado:", pivot, "\n")
  }

  # Crear objeto clustering
  if (verbose) cat("   - Ejecutando algoritmo de clustering...\n")
  clustering_obj <- Clustering$new(
    rollcalls = rollcall_matrix,
    N = distance_method,
    pivot = pivot
  )

  # Preparar resultado
  result <- list(
    clustering_df = clustering_obj$clustering,
    clustering_object = clustering_obj,
    rollcall_matrix = rollcall_matrix,
    metadata = list(
      distance_method = distance_method,
      distance_name = if(distance_method == 1) "Manhattan" else if(distance_method == 2) "Euclidiana" else "Desconocida",
      pivot_used = pivot,
      legislators_count = nrow(rollcall_matrix),
      votaciones_count = ncol(rollcall_matrix),
      clustering_date = Sys.time()
    )
  )

  if (verbose) {
    cat("✅ CLUSTERING COMPLETADO\n")
    cat("   - Distribución de clusters:\n")
    cluster_table <- table(clustering_obj$clustering$cluster)
    for (cluster_name in names(cluster_table)) {
      cat("     *", cluster_name, ":", cluster_table[cluster_name], "legisladores\n")
    }
  }

  return(result)
}

#' Automatic B-Call analysis with clustering
#'
#' @description
#' Performs automatic clustering followed by B-Call analysis in one step.
#' This is the equivalent of the complete workflow from Correlation.ipynb.
#'
#' @param rollcall_data Output from excel_to_rollcall() function
#' @param distance_method Integer, distance metric (1 = Manhattan, 2 = Euclidean)
#' @param pivot Character, pivot legislator name (NULL for automatic selection)
#' @param threshold Numeric, minimum participation threshold for B-Call
#' @param verbose Logical, whether to print progress messages
#'
#' @return List containing complete analysis results
#'
#' @examples
#' \dontrun{
#' rollcall_data <- excel_to_rollcall("legis.xlsx", "votos.xlsx")
#' full_results <- auto_bcall_with_clustering(rollcall_data)
#' plot_bcall_analysis_interactive(full_results)
#' }
#'
#' @export
auto_bcall_with_clustering <- function(rollcall_data, distance_method = 1, pivot = NULL, threshold = 0.1, verbose = TRUE) {

  if (verbose) cat("=== ANÁLISIS B-CALL CON CLUSTERING AUTOMÁTICO ===\n")

  # 1. Clustering automático
  if (verbose) cat("\n1. Ejecutando clustering automático...\n")
  clustering_result <- auto_clustering_from_rollcall(
    rollcall_data = rollcall_data,
    distance_method = distance_method,
    pivot = pivot,
    verbose = verbose
  )

  # 2. Seleccionar pivot para B-Call
  if (is.null(pivot)) {
    # Buscar un legislador del cluster "right" con alta participación
    right_legislators <- rownames(clustering_result$clustering_df)[clustering_result$clustering_df$cluster == "right"]

    if (length(right_legislators) > 0) {
      # Calcular participación para legisladores de derecha
      participation <- 1 - rowSums(is.na(clustering_result$rollcall_matrix[right_legislators, , drop = FALSE])) / ncol(clustering_result$rollcall_matrix)
      pivot_bcall <- names(participation)[which.max(participation)]
      if (verbose) cat("\n2. Pivot para B-Call seleccionado automáticamente (cluster 'right'):", pivot_bcall, "\n")
    } else {
      # Usar el mismo pivot del clustering
      pivot_bcall <- clustering_result$metadata$pivot_used
      if (verbose) cat("\n2. Usando mismo pivot del clustering para B-Call:", pivot_bcall, "\n")
    }
  } else {
    pivot_bcall <- pivot
    if (verbose) cat("\n2. Pivot para B-Call especificado:", pivot_bcall, "\n")
  }

  # 3. Ejecutar B-Call
  if (verbose) cat("\n3. Ejecutando análisis B-Call...\n")
  bcall_obj <- BCall$new(
    rollcall = clustering_result$rollcall_matrix,
    clustering = clustering_result$clustering_df,
    pivot = pivot_bcall,
    threshold = threshold
  )

  # 4. Preparar resultados finales
  results_df <- bcall_obj$stats
  results_df$nm_y_apellidos <- rownames(results_df)

  # Agregar información de clustering
  results_df <- merge(results_df, clustering_result$clustering_df, by.x = "nm_y_apellidos", by.y = "row.names", all.x = TRUE)
  names(results_df)[names(results_df) == "cluster"] <- "auto_cluster"

  # Agregar información de partido si está disponible
  if ("legislators_info" %in% names(rollcall_data)) {
    results_df <- merge(results_df, rollcall_data$legislators_info, by = "nm_y_apellidos", all.x = TRUE)
  }

  # Estructura final
  final_result <- list(
    results = results_df,
    bcall_object = bcall_obj,
    clustering_result = clustering_result,
    rollcall_matrix = clustering_result$rollcall_matrix,
    clustering_df = clustering_result$clustering_df,
    metadata = list(
      clustering_method = clustering_result$metadata$distance_name,
      distance_method = distance_method,
      pivot_used = pivot_bcall,
      threshold_used = threshold,
      legislators_count = nrow(clustering_result$rollcall_matrix),
      votaciones_count = ncol(clustering_result$rollcall_matrix),
      analysis_date = Sys.time(),
      workflow = "Automatic Clustering + B-Call"
    )
  )

  if (verbose) {
    cat("✅ ANÁLISIS B-CALL COMPLETADO\n")
    cat("   - d1 (posición ideológica): rango [", round(min(results_df$d1, na.rm = TRUE), 3),
        ", ", round(max(results_df$d1, na.rm = TRUE), 3), "]\n")
    cat("   - d2 (cohesión política): rango [", round(min(results_df$d2, na.rm = TRUE), 3),
        ", ", round(max(results_df$d2, na.rm = TRUE), 3), "]\n")
    cat("   - Clustering automático:", clustering_result$metadata$distance_name, "\n")
    cat("   - Total legisladores analizados:", nrow(results_df), "\n")
  }

  return(final_result)
}

#' Complete workflow: Excel to B-Call with automatic clustering
#'
#' @description
#' Complete workflow that goes from Excel files to B-Call results with automatic clustering.
#' This is the most convenient function for users who want everything automated.
#'
#' @param legislators_file Path to Excel file with legislators information
#' @param votes_file Path to Excel file with votes data
#' @param distance_method Integer, distance metric (1 = Manhattan, 2 = Euclidean)
#' @param pivot Character, pivot legislator name (NULL for automatic selection)
#' @param threshold Numeric, minimum participation threshold for B-Call
#' @param verbose Logical, whether to print progress messages
#'
#' @return List containing complete analysis results ready for plotting
#'
#' @examples
#' \dontrun{
#' # Complete workflow in one function
#' results <- excel_to_bcall_auto(
#'   "legisladores.xlsx",
#'   "votos.xlsx",
#'   distance_method = 1
#' )
#' plot_bcall_analysis_interactive(results)
#' }
#'
#' @export
excel_to_bcall_auto <- function(legislators_file, votes_file, distance_method = 1, pivot = NULL, threshold = 0.1, verbose = TRUE) {

  if (verbose) cat("=== WORKFLOW COMPLETO: EXCEL → CLUSTERING → B-CALL ===\n")

  # 1. Cargar datos desde Excel
  if (verbose) cat("\n1. Cargando datos desde Excel...\n")
  rollcall_data <- excel_to_rollcall(
    legislators_file = legislators_file,
    votes_file = votes_file
  )

  # 2. Análisis completo con clustering automático
  if (verbose) cat("\n2. Iniciando análisis con clustering automático...\n")
  results <- auto_bcall_with_clustering(
    rollcall_data = rollcall_data,
    distance_method = distance_method,
    pivot = pivot,
    threshold = threshold,
    verbose = verbose
  )

  if (verbose) {
    cat("\n✅ WORKFLOW COMPLETO TERMINADO\n")
    cat("🎯 Resultados listos para:\n")
    cat("   - plot_bcall_analysis_interactive(results)\n")
    cat("   - summarize_bcall_analysis(results)\n")
    cat("   - export_bcall_analysis(results, 'output_folder')\n")
  }

  return(results)
}