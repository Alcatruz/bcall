# ===============================================================================
# FUNCIÓN PARA CONVERTIR DATOS EXCEL A FORMATO ROLLCALL
# ===============================================================================

#' Convert Excel data to rollcall matrix format
#'
#' @description
#' Converts Excel files with legislators and votes data into rollcall matrix format
#' suitable for B-Call analysis. Handles the transformation from long format votes
#' to wide format matrix with legislators as rows and votaciones as columns.
#'
#' @param legislators_file Path to Excel file with legislators information
#' @param votes_file Path to Excel file with votes data
#' @param legislators_sheet Sheet name or index for legislators data (default: 1)
#' @param votes_sheet Sheet name or index for votes data (default: 1)
#'
#' @return List containing:
#'   \itemize{
#'     \item rollcall_matrix: Wide format matrix (legislators x votaciones)
#'     \item legislators_info: DataFrame with legislator information
#'     \item votes_summary: Summary of voting data
#'   }
#'
#' @examples
#' \dontrun{
#' # Convert Excel data to rollcall format
#' rollcall_data <- excel_to_rollcall(
#'   legislators_file = "data/legist_chile.xlsx",
#'   votes_file = "data/votes_chile.xlsx"
#' )
#'
#' # Use with B-Call analysis
#' analysis <- BCallAnalysis$new()
#' result <- analysis$run_analysis_from_rollcall(rollcall_data)
#' }
#'
#' @export
excel_to_rollcall <- function(legislators_file, votes_file,
                             legislators_sheet = 1, votes_sheet = 1) {

  # Verificar que readxl esté disponible
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Package 'readxl' is required but not installed. Install with: install.packages('readxl')")
  }

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required but not installed. Install with: install.packages('dplyr')")
  }

  cat("=== CONVIRTIENDO DATOS EXCEL A FORMATO ROLLCALL ===\n")

  # -------------------------------------------------------------------------
  # 1. LEER DATOS DE LEGISLADORES
  # -------------------------------------------------------------------------
  cat("\n1. Leyendo datos de legisladores...\n")

  if (!file.exists(legislators_file)) {
    stop(paste("Archivo de legisladores no encontrado:", legislators_file))
  }

  legislators_data <- readxl::read_excel(legislators_file, sheet = legislators_sheet)

  cat("   - Archivo:", legislators_file, "\n")
  cat("   - Dimensiones:", nrow(legislators_data), "filas x", ncol(legislators_data), "columnas\n")
  cat("   - Columnas:", paste(colnames(legislators_data), collapse = ", "), "\n")

  # Verificar columnas requeridas
  required_cols_leg <- c("nm_y_apellidos")
  missing_cols <- setdiff(required_cols_leg, colnames(legislators_data))

  if (length(missing_cols) > 0) {
    stop(paste("Columnas faltantes en legislators:", paste(missing_cols, collapse = ", ")))
  }

  # Limpiar nombres de legisladores
  legislators_data$nm_y_apellidos <- gsub("[^[:alnum:][:space:]áéíóúüñÁÉÍÓÚÜÑ_.-]", "", legislators_data$nm_y_apellidos)
  legislators_data$nm_y_apellidos <- gsub("\\\\s+", "_", legislators_data$nm_y_apellidos)

  cat("   - Legisladores únicos:", length(unique(legislators_data$nm_y_apellidos)), "\n")

  # -------------------------------------------------------------------------
  # 2. LEER DATOS DE VOTOS
  # -------------------------------------------------------------------------
  cat("\n2. Leyendo datos de votos...\n")

  if (!file.exists(votes_file)) {
    stop(paste("Archivo de votos no encontrado:", votes_file))
  }

  votes_data <- readxl::read_excel(votes_file, sheet = votes_sheet)

  cat("   - Archivo:", votes_file, "\n")
  cat("   - Dimensiones:", nrow(votes_data), "filas x", ncol(votes_data), "columnas\n")
  cat("   - Columnas:", paste(colnames(votes_data), collapse = ", "), "\n")

  # Verificar columnas requeridas en votos
  required_cols_votes <- c("nm_y_apellidos", "votacion_id", "voto")
  missing_cols_votes <- setdiff(required_cols_votes, colnames(votes_data))

  if (length(missing_cols_votes) > 0) {
    stop(paste("Columnas faltantes en votes:", paste(missing_cols_votes, collapse = ", ")))
  }

  # Limpiar nombres en votos (mismo formato que legisladores)
  votes_data$nm_y_apellidos <- gsub("[^[:alnum:][:space:]áéíóúüñÁÉÍÓÚÜÑ_.-]", "", votes_data$nm_y_apellidos)
  votes_data$nm_y_apellidos <- gsub("\\\\s+", "_", votes_data$nm_y_apellidos)

  cat("   - Registros de votos:", nrow(votes_data), "\n")
  cat("   - Legisladores únicos:", length(unique(votes_data$nm_y_apellidos)), "\n")
  cat("   - Votaciones únicas:", length(unique(votes_data$votacion_id)), "\n")
  cat("   - Tipos de voto:", paste(sort(unique(votes_data$voto)), collapse = ", "), "\n")

  # -------------------------------------------------------------------------
  # 3. VERIFICAR CONSISTENCIA
  # -------------------------------------------------------------------------
  cat("\n3. Verificando consistencia de datos...\n")

  # Legisladores comunes
  common_legislators <- intersect(legislators_data$nm_y_apellidos, votes_data$nm_y_apellidos)

  cat("   - Legisladores en archivo de legisladores:", nrow(legislators_data), "\n")
  cat("   - Legisladores con votos:", length(unique(votes_data$nm_y_apellidos)), "\n")
  cat("   - Coincidencias:", length(common_legislators), "\n")
  cat("   - Porcentaje de coincidencia:", round(length(common_legislators) / nrow(legislators_data) * 100, 1), "%\n")

  if (length(common_legislators) < nrow(legislators_data) * 0.8) {
    warning("Menos del 80% de legisladores tienen votos registrados")

    missing_legislators <- setdiff(legislators_data$nm_y_apellidos, votes_data$nm_y_apellidos)
    cat("   - Legisladores sin votos (primeros 5):", paste(head(missing_legislators, 5), collapse = ", "), "\n")
  }

  # Filtrar solo legisladores que aparecen en ambos archivos
  legislators_filtered <- legislators_data[legislators_data$nm_y_apellidos %in% common_legislators, ]
  votes_filtered <- votes_data[votes_data$nm_y_apellidos %in% common_legislators, ]

  # -------------------------------------------------------------------------
  # 4. CREAR MATRIZ ROLLCALL
  # -------------------------------------------------------------------------
  cat("\n4. Creando matriz rollcall...\n")

  # Convertir votos a formato estándar B-Call: 1 = A favor, -1 = En contra, 0 = Abstención/Dispensado/No Vota
  # IMPORTANTE: B-Call original maneja 1, -1, 0 (donde 0 = abstención)
  # Solo las celdas completamente vacías (sin votación) deben ser NA

  cat("   - Tipos de voto encontrados:", paste(unique(votes_filtered$voto), collapse = ", "), "\n")

  votes_filtered$voto_numeric <- NA
  # Votos afirmativos (a favor) = 1
  votes_filtered$voto_numeric[votes_filtered$voto %in% c("Afirmativo", "Sí", "Si", "YES", "1", "A favor", "Afavor")] <- 1
  # Votos negativos (en contra) = -1
  votes_filtered$voto_numeric[votes_filtered$voto %in% c("En Contra", "No", "NO", "-1", "En contra", "Encontra")] <- -1
  # Abstenciones, dispensados y no votos = 0 (NO NA!)
  votes_filtered$voto_numeric[votes_filtered$voto %in% c("Abstención", "Dispensado", "No Vota", "Abstencion", "0")] <- 0

  # Mostrar conversión detallada por tipo original
  cat("   - Conversión de tipos de voto:\n")
  original_vote_table <- table(votes_filtered$voto)
  for (voto_original in names(original_vote_table)) {
    count_original <- original_vote_table[voto_original]
    if (voto_original == "Afirmativo") {
      cat(sprintf("     '%s' → 1 (a favor): %d votos\n", voto_original, count_original))
    } else if (voto_original == "En Contra") {
      cat(sprintf("     '%s' → -1 (en contra): %d votos\n", voto_original, count_original))
    } else if (voto_original %in% c("Abstención", "Dispensado", "No Vota", "Abstencion", "0")) {
      cat(sprintf("     '%s' → 0 (abstención): %d votos\n", voto_original, count_original))
    } else {
      cat(sprintf("     '%s' → NA (no participó): %d votos\n", voto_original, count_original))
    }
  }

  cat("   - Distribución final (numérica):\n")
  vote_table <- table(votes_filtered$voto_numeric, useNA = "always")
  for (i in seq_along(vote_table)) {
    vote_val <- names(vote_table)[i]
    if (is.na(vote_val)) {
      cat(sprintf("     NA (no participó en votación): %d votos\n", vote_table[i]))
    } else {
      voto_texto <- if(vote_val == "1") "a favor" else if(vote_val == "-1") "en contra" else if(vote_val == "0") "abstención" else "desconocido"
      cat(sprintf("     %s (%s): %d votos\n", vote_val, voto_texto, vote_table[i]))
    }
  }

  # Crear matriz rollcall usando reshape
  library(dplyr)

  rollcall_long <- votes_filtered %>%
    select(nm_y_apellidos, votacion_id, voto_numeric) %>%
    filter(!is.na(nm_y_apellidos) & !is.na(votacion_id))

  # Convertir a matriz wide
  rollcall_matrix <- rollcall_long %>%
    tidyr::pivot_wider(
      names_from = votacion_id,
      values_from = voto_numeric,
      values_fill = NA
    ) %>%
    as.data.frame()

  # ASEGURAR QUE ES DATA.FRAME CON ROWNAMES
  if (inherits(rollcall_matrix, "tbl_df")) {
    rollcall_matrix <- as.data.frame(rollcall_matrix)
  }

  # Establecer nombres de filas
  rownames(rollcall_matrix) <- rollcall_matrix$nm_y_apellidos
  rollcall_matrix$nm_y_apellidos <- NULL

  cat("   - Matriz rollcall creada:\n")
  cat("     * Legisladores (filas):", nrow(rollcall_matrix), "\n")
  cat("     * Votaciones (columnas):", ncol(rollcall_matrix), "\n")
  cat("     * Total de celdas:", nrow(rollcall_matrix) * ncol(rollcall_matrix), "\n")

  # Calcular estadísticas de completitud
  total_cells <- nrow(rollcall_matrix) * ncol(rollcall_matrix)
  missing_cells <- sum(is.na(rollcall_matrix))
  completeness <- round((total_cells - missing_cells) / total_cells * 100, 1)

  cat("     * Celdas con datos:", total_cells - missing_cells, "\n")
  cat("     * Celdas vacías:", missing_cells, "\n")
  cat("     * Completitud:", completeness, "%\n")

  # -------------------------------------------------------------------------
  # 5. PREPARAR RESULTADO
  # -------------------------------------------------------------------------
  cat("\n5. Preparando resultado final...\n")

  # Resumen de votos
  votes_summary <- list(
    total_votes = nrow(votes_filtered),
    unique_legislators = length(unique(votes_filtered$nm_y_apellidos)),
    unique_votaciones = length(unique(votes_filtered$votacion_id)),
    vote_distribution = table(votes_filtered$voto_numeric, useNA = "always"),
    completeness_percent = completeness
  )

  result <- list(
    rollcall_matrix = rollcall_matrix,
    legislators_info = legislators_filtered,
    votes_summary = votes_summary,
    original_votes = votes_filtered
  )

  cat("\n✅ CONVERSIÓN COMPLETADA EXITOSAMENTE\n")
  cat("   - Formato rollcall listo para análisis B-Call\n")
  cat("   - Use el objeto $rollcall_matrix para análisis\n")
  cat("   - Use el objeto $legislators_info para información de partidos\n")

  return(result)
}


#' Run B-Call analysis from rollcall data
#'
#' @description
#' Convenience function to run B-Call analysis directly from rollcall data
#' generated by excel_to_rollcall()
#'
#' @param rollcall_data Output from excel_to_rollcall() function
#' @param ... Additional parameters for B-Call analysis
#'
#' @return B-Call analysis results
#'
#' @examples
#' \dontrun{
#' # Complete workflow from Excel to B-Call results
#' rollcall_data <- excel_to_rollcall("legist_chile.xlsx", "votes_chile.xlsx")
#' results <- run_bcall_from_rollcall(rollcall_data)
#' }
#'
#' @export
run_bcall_from_rollcall <- function(rollcall_data, pivot = NULL, threshold = 0.1, auto_pivot = TRUE, ...) {

  if (!inherits(rollcall_data, "list") ||
      !all(c("rollcall_matrix", "legislators_info") %in% names(rollcall_data))) {
    stop("rollcall_data debe ser el resultado de excel_to_rollcall()")
  }

  cat("=== EJECUTANDO ANÁLISIS B-CALL DESDE ROLLCALL ===\n")

  # Preparar datos en formato B-Call
  rollcall_matrix <- rollcall_data$rollcall_matrix
  legislators_info <- rollcall_data$legislators_info

  # ASEGURAR QUE rollcall_matrix ES DATA.FRAME CON ROWNAMES
  if (inherits(rollcall_matrix, "tbl_df")) {
    # Preservar rownames si los tiene
    if (!is.null(rownames(rollcall_matrix)) && length(rownames(rollcall_matrix)) > 0) {
      row_names_backup <- rownames(rollcall_matrix)
      rollcall_matrix <- as.data.frame(rollcall_matrix)
      rownames(rollcall_matrix) <- row_names_backup
    } else {
      rollcall_matrix <- as.data.frame(rollcall_matrix)
    }
  }

  # Crear DataFrame de clustering desde legislators_info
  clustering_df <- data.frame(
    cluster = legislators_info$party,
    row.names = legislators_info$nm_y_apellidos
  )

  # Verificar que clustering_df tenga exactamente los mismos legisladores que rollcall_matrix
  common_legislators <- intersect(rownames(rollcall_matrix), rownames(clustering_df))

  if (length(common_legislators) == 0) {
    stop("No hay legisladores comunes entre rollcall_matrix y clustering_df")
  }

  # Filtrar para que coincidan
  rollcall_matrix <- rollcall_matrix[common_legislators, ]
  clustering_df <- clustering_df[common_legislators, , drop = FALSE]

  cat("   - Matriz rollcall: ", nrow(rollcall_matrix), " legisladores x ", ncol(rollcall_matrix), " votaciones\n")
  cat("   - Clustering: ", nrow(clustering_df), " legisladores en ", length(unique(clustering_df$cluster)), " clusters\n")

  # Seleccionar pivot automáticamente si no se especifica
  if (is.null(pivot) && auto_pivot) {
    # Buscar un legislador del cluster "right" con alta participación
    right_legislators <- rownames(clustering_df)[clustering_df$cluster == "right"]

    if (length(right_legislators) > 0) {
      # Calcular participación para legisladores de derecha
      participation <- 1 - rowSums(is.na(rollcall_matrix[right_legislators, , drop = FALSE])) / ncol(rollcall_matrix)
      pivot <- names(participation)[which.max(participation)]
      cat("   - Pivot seleccionado automáticamente (cluster 'right'):", pivot, "\n")
    } else {
      stop("No se encontraron legisladores en el cluster 'right' para seleccionar pivot automáticamente")
    }
  }

  if (is.null(pivot)) {
    stop("Debe especificar un pivot o usar auto_pivot = TRUE")
  }

  # Crear objeto BCall
  cat("   - Creando objeto BCall...\n")
  bcall_obj <- BCall$new(
    rollcall = rollcall_matrix,
    clustering = clustering_df,
    pivot = pivot,
    threshold = threshold
  )

  # Extraer resultados
  results_df <- bcall_obj$stats
  results_df$nm_y_apellidos <- rownames(results_df)

  # Agregar información de partido
  results_df <- merge(results_df, legislators_info, by = "nm_y_apellidos", all.x = TRUE)

  # Crear estructura de resultado compatible
  result <- list(
    results = results_df,
    bcall_object = bcall_obj,
    rollcall_matrix = rollcall_matrix,
    clustering_df = clustering_df,
    metadata = list(
      pivot_used = pivot,
      threshold_used = threshold,
      legislators_count = nrow(rollcall_matrix),
      votaciones_count = ncol(rollcall_matrix),
      analysis_date = Sys.time()
    )
  )

  cat("✅ ANÁLISIS B-CALL COMPLETADO\n")
  cat("   - d1 (posición ideológica): rango [", round(min(results_df$d1, na.rm = TRUE), 3),
      ", ", round(max(results_df$d1, na.rm = TRUE), 3), "]\n")
  cat("   - d2 (cohesión política): rango [", round(min(results_df$d2, na.rm = TRUE), 3),
      ", ", round(max(results_df$d2, na.rm = TRUE), 3), "]\n")

  return(result)
}