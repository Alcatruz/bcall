#' Get package data path
#'
#' @description Helper function to locate package data files
#' @param filename Character, name of the data file
#' @return Character, full path to the data file
#' @export
get_bcall_data <- function(filename) {
  data_path <- system.file("extdata", filename, package = "bcall")

  if (data_path == "") {
    stop(sprintf("Data file '%s' not found in package. Available files: %s",
                filename,
                paste(list.files(system.file("extdata", package = "bcall")),
                      collapse = ", ")))
  }

  return(data_path)
}

#' List available sample data
#'
#' @description Lists all sample data files included with the package
#' @return Character vector of available data files
#' @export
list_bcall_data <- function() {
  data_dir <- system.file("extdata", package = "bcall")
  if (data_dir == "") {
    return(character(0))
  }

  files <- list.files(data_dir)
  cat("Available sample data files:\n")
  for (file in files) {
    cat(sprintf("  %s\n", file))
  }

  return(invisible(files))
}