# ===============================================================================
# FUNCIONES PARA ROLLCALL DIRECTO DESDE CSV
# ===============================================================================

#' Load rollcall matrix directly from CSV
#'
#' @description
#' Loads a rollcall matrix directly from CSV format where rows are legislators
#' and columns are voting sessions. Automatically detects legislator names
#' and prepares data for clustering and B-Call analysis.
#'
#' @param rollcall_csv_file Path to CSV file with rollcall matrix
#' @param verbose Logical, whether to print progress messages
#'
#' @return List containing rollcall matrix and basic legislator info
#'
#' @examples
#' \dontrun{
#' rollcall_data <- load_rollcall_direct("C:/path/to/CHL-DIP-2022.csv")
#' }
#'
#' @export
load_rollcall_direct <- function(rollcall_csv_file, verbose = TRUE) {

  if (verbose) cat("=== CARGANDO ROLLCALL DIRECTO DESDE CSV ===\n")

  if (!file.exists(rollcall_csv_file)) {
    stop(paste("Archivo CSV no encontrado:", rollcall_csv_file))
  }

  if (verbose) cat("   - Archivo:", rollcall_csv_file, "\n")

  # Leer CSV con primera columna como nombres de filas
  rollcall_matrix <- read.csv(rollcall_csv_file, row.names = 1, stringsAsFactors = FALSE)

  # ASEGURAR QUE ES DATA.FRAME CON ROWNAMES
  if (inherits(rollcall_matrix, "tbl_df")) {
    rollcall_matrix <- as.data.frame(rollcall_matrix)
  }

  if (verbose) {
    cat("   - Dimensiones:", nrow(rollcall_matrix), "legisladores x", ncol(rollcall_matrix), "votaciones\n")
    cat("   - Primeros legisladores:", paste(head(rownames(rollcall_matrix), 3), collapse = ", "), "\n")
    cat("   - Primeras votaciones:", paste(head(colnames(rollcall_matrix), 3), collapse = ", "), "\n")
  }

  # Verificar tipos de datos y limpiar
  if (verbose) cat("   - Verificando tipos de datos...\n")

  # Contar tipos de valores
  unique_values <- unique(as.vector(as.matrix(rollcall_matrix)))
  unique_values <- unique_values[!is.na(unique_values)]

  if (verbose) {
    cat("   - Valores únicos encontrados:", paste(sort(unique_values), collapse = ", "), "\n")
  }

  # Convertir a numérico si es necesario
  rollcall_matrix <- as.data.frame(lapply(rollcall_matrix, function(x) {
    if (is.character(x)) {
      as.numeric(x)
    } else {
      x
    }
  }))

  # Restaurar nombres de filas
  rownames(rollcall_matrix) <- rownames(read.csv(rollcall_csv_file, row.names = 1, stringsAsFactors = FALSE))

  # Calcular estadísticas de completitud
  total_cells <- nrow(rollcall_matrix) * ncol(rollcall_matrix)
  missing_cells <- sum(is.na(rollcall_matrix))
  completeness <- round((total_cells - missing_cells) / total_cells * 100, 1)

  if (verbose) {
    cat("   - Celdas totales:", total_cells, "\n")
    cat("   - Celdas con datos:", total_cells - missing_cells, "\n")
    cat("   - Celdas vacías (NA):", missing_cells, "\n")
    cat("   - Completitud:", completeness, "%\n")

    # Distribución de valores
    cat("   - Distribución de valores:\n")
    value_table <- table(as.vector(as.matrix(rollcall_matrix)), useNA = "always")
    for (i in seq_along(value_table)) {
      val_name <- names(value_table)[i]
      if (is.na(val_name)) {
        cat("     NA (ausente):", value_table[i], "\n")
      } else {
        val_text <- if(val_name == "1") "a favor" else if(val_name == "-1") "en contra" else if(val_name == "0") "abstención" else "otro"
        cat("     ", val_name, "(", val_text, "):", value_table[i], "\n")
      }
    }
  }

  # Crear información básica de legisladores
  legislators_info <- data.frame(
    nm_y_apellidos = rownames(rollcall_matrix),
    stringsAsFactors = FALSE
  )

  # Calcular participación por legislador
  legislators_info$participation <- 1 - rowSums(is.na(rollcall_matrix)) / ncol(rollcall_matrix)

  # Preparar resultado
  result <- list(
    rollcall_matrix = rollcall_matrix,
    legislators_info = legislators_info,
    metadata = list(
      source_file = rollcall_csv_file,
      legislators_count = nrow(rollcall_matrix),
      votaciones_count = ncol(rollcall_matrix),
      completeness_percent = completeness,
      load_date = Sys.time()
    )
  )

  if (verbose) {
    cat("✅ ROLLCALL CARGADO EXITOSAMENTE\n")
    cat("   - Listo para clustering automático\n")
    cat("   - Use generate_clustering_from_rollcall_direct() para continuar\n")
  }

  return(result)
}

#' Generate clustering from direct rollcall CSV
#'
#' @description
#' Performs automatic clustering on rollcall data loaded directly from CSV.
#' This is a wrapper that combines load_rollcall_direct() with clustering generation.
#'
#' @param rollcall_csv_file Path to CSV file with rollcall matrix
#' @param distance_method Integer, distance metric (1 = Manhattan, 2 = Euclidean)
#' @param pivot Character, pivot legislator name (NULL for automatic selection)
#' @param verbose Logical, whether to print progress messages
#'
#' @return Rollcall data with automatic clustering
#'
#' @examples
#' \dontrun{
#' rollcall_with_clusters <- generate_clustering_from_rollcall_direct(
#'   "C:/path/to/CHL-DIP-2022.csv",
#'   distance_method = 1,
#'   pivot = "Becker_Alvear_Gonzalo"
#' )
#' }
#'
#' @export
generate_clustering_from_rollcall_direct <- function(rollcall_csv_file, distance_method = 1, pivot = NULL, verbose = TRUE) {

  if (verbose) cat("=== CLUSTERING AUTOMÁTICO DESDE ROLLCALL CSV ===\n")

  # 1. Cargar rollcall directo
  rollcall_data <- load_rollcall_direct(rollcall_csv_file, verbose = verbose)

  # 2. Generar clustering automático
  if (verbose) cat("\n--- GENERANDO CLUSTERING AUTOMÁTICO ---\n")

  rollcall_matrix <- rollcall_data$rollcall_matrix

  # Selección automática de pivot si no se especifica
  if (is.null(pivot)) {
    pivot <- rownames(rollcall_matrix)[1]
    if (verbose) cat("   - Pivot seleccionado automáticamente:", pivot, "\n")
  } else {
    if (verbose) cat("   - Pivot especificado:", pivot, "\n")
  }

  # Verificar que el pivot existe
  if (!pivot %in% rownames(rollcall_matrix)) {
    available_legislators <- rownames(rollcall_matrix)[1:min(5, nrow(rollcall_matrix))]
    stop(paste("Pivot '", pivot, "' no encontrado. Legisladores disponibles (primeros 5):",
               paste(available_legislators, collapse = ", ")))
  }

  # Crear objeto clustering
  if (verbose) cat("   - Ejecutando algoritmo de clustering...\n")
  distance_name <- if(distance_method == 1) "Manhattan" else if(distance_method == 2) "Euclidiana" else "Desconocida"
  cat("   - Método de distancia:", distance_name, "\n")

  clustering_obj <- Clustering$new(
    rollcalls = rollcall_matrix,
    N = distance_method,
    pivot = pivot
  )

  # Obtener clustering resultados
  clustering_df <- clustering_obj$clustering

  if (verbose) {
    cat("   - Distribución de clusters generados:\n")
    cluster_table <- table(clustering_df$cluster)
    for (cluster_name in names(cluster_table)) {
      cat("     *", cluster_name, ":", cluster_table[cluster_name], "legisladores\n")
    }
  }

  # Actualizar legislators_info con clustering
  clustering_df$nm_y_apellidos <- rownames(clustering_df)
  # Renombrar 'cluster' a 'auto_cluster' para compatibilidad
  names(clustering_df)[names(clustering_df) == "cluster"] <- "auto_cluster"
  updated_legislators <- merge(rollcall_data$legislators_info, clustering_df, by = "nm_y_apellidos", all.x = TRUE)

  # Crear resultado final
  result <- rollcall_data
  result$legislators_info <- updated_legislators
  result$clustering_metadata <- list(
    distance_method = distance_method,
    distance_name = distance_name,
    pivot_used = pivot,
    clustering_date = Sys.time(),
    source_file = rollcall_csv_file
  )

  if (verbose) {
    cat("✅ CLUSTERING GENERADO DESDE CSV\n")
    cat("   - Datos listos para run_bcall_with_auto_clusters()\n")
  }

  return(result)
}

#' Complete workflow: CSV rollcall to B-Call analysis
#'
#' @description
#' Complete workflow from CSV rollcall file to B-Call analysis with automatic clustering.
#' This function handles everything in one step.
#'
#' @param rollcall_csv_file Path to CSV file with rollcall matrix
#' @param distance_method Integer, distance metric (1 = Manhattan, 2 = Euclidean)
#' @param pivot Character, pivot legislator name (NULL for automatic selection)
#' @param threshold Numeric, minimum participation threshold for B-Call
#' @param verbose Logical, whether to print progress messages
#'
#' @return Complete B-Call analysis results
#'
#' @examples
#' \dontrun{
#' results <- rollcall_directo_to_bcall(
#'   "C:/Users/alcacplt/B-Call/rctipo/CHL-DIP-2022.csv",
#'   distance_method = 1,
#'   pivot = "Becker_Alvear_Gonzalo"
#' )
#' plot_bcall_analysis_interactive(results)
#' }
#'
#' @export
rollcall_directo_to_bcall <- function(rollcall_csv_file, distance_method = 1, pivot = NULL, threshold = 0.1, verbose = TRUE) {

  if (verbose) cat("=== WORKFLOW COMPLETO: CSV ROLLCALL → CLUSTERING → B-CALL ===\n")

  # 1. Clustering automático desde CSV
  rollcall_with_clusters <- generate_clustering_from_rollcall_direct(
    rollcall_csv_file = rollcall_csv_file,
    distance_method = distance_method,
    pivot = pivot,
    verbose = verbose
  )

  # 2. B-Call con clustering automático
  if (verbose) cat("\n--- EJECUTANDO ANÁLISIS B-CALL ---\n")
  results <- run_bcall_with_auto_clusters(
    rollcall_data_with_clusters = rollcall_with_clusters,
    pivot = pivot,
    threshold = threshold,
    verbose = verbose
  )

  # Agregar información del archivo fuente a metadata
  results$metadata$source_csv_file <- rollcall_csv_file
  results$metadata$workflow <- "Direct CSV to B-Call"

  if (verbose) {
    cat("\n✅ WORKFLOW COMPLETO TERMINADO\n")
    cat("🎯 Archivo procesado:", basename(rollcall_csv_file), "\n")
    cat("📊 Resultados listos para:\n")
    cat("   - plot_bcall_analysis_interactive(results)\n")
    cat("   - summarize_bcall_analysis(results)\n")
    cat("   - export_bcall_analysis(results, 'output_folder')\n")
  }

  return(results)
}