#' Load sample rollcall data as objects
#'
#' @description Load rollcall data directly as R objects without temp files
#' @param dataset Character, name of dataset to load
#' @return Data.frame with rollcall matrix
#' @export
load_sample_rollcall <- function(dataset = "usa_2021") {

  valid_datasets <- c("usa_2021", "usa_2022")

  if (!dataset %in% valid_datasets) {
    stop(sprintf("Dataset '%s' not available. Valid options: %s",
                dataset, paste(valid_datasets, collapse = ", ")))
  }

  if (dataset == "usa_2021") {
    file_path <- system.file("extdata", "USA-House-2021-rollcall.csv", package = "bcall")
  } else if (dataset == "usa_2022") {
    file_path <- system.file("extdata", "USA-House-2022-rollcall.csv", package = "bcall")
  }

  if (file_path == "") {
    stop(sprintf("Data file for '%s' not found in package", dataset))
  }

  cat(sprintf("Loading %s rollcall data...\n", dataset))
  data <- read.csv(file_path, row.names = 1)
  cat(sprintf("Loaded: %d legislators x %d votes\n", nrow(data), ncol(data)))

  return(data)
}

#' Load sample data for excel workflow
#'
#' @description Load Chilean Excel data for Path 1 workflow
#' @return List with file paths for excel_to_rollcall()
#' @export
load_sample_excel_paths <- function() {

  legist_file <- system.file("extdata", "legist_chile.xlsx", package = "bcall")
  votes_file <- system.file("extdata", "votes_chile.xlsx", package = "bcall")

  if (legist_file == "" || votes_file == "") {
    stop("Chilean Excel files not found in package")
  }

  cat("Chilean Excel data paths ready for excel_to_rollcall()\n")

  return(list(
    legist_file = legist_file,
    votes_file = votes_file
  ))
}