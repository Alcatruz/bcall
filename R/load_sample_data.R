#' Load Chilean sample data directly (Excel format)
#'
#' @description Load Chilean legislative data and convert to rollcall format
#' @return List with rollcall_matrix and legislators_info
#' @export
load_chile_sample <- function() {

  legist_file <- system.file("extdata", "legist_chile.xlsx", package = "bcall")
  votes_file <- system.file("extdata", "votes_chile.xlsx", package = "bcall")

  if (legist_file == "" || votes_file == "") {
    stop("Chilean Excel files not found in package")
  }

  cat("Loading Chilean sample data...\n")
  rollcall_data <- excel_to_rollcall(legist_file, votes_file)
  cat("Chilean data ready for run_bcall_from_rollcall()\n")

  return(rollcall_data)
}

#' Load USA rollcall sample data (CSV format)
#'
#' @description Load USA rollcall data directly as matrix
#' @param year Character, year to load ("2021" or "2022")
#' @return Data.frame with rollcall matrix
#' @export
load_usa_rollcall <- function(year = "2021") {

  if (year == "2021") {
    file_path <- system.file("extdata", "USA-House-2021-rollcall.csv", package = "bcall")
  } else if (year == "2022") {
    file_path <- system.file("extdata", "USA-House-2022-rollcall.csv", package = "bcall")
  } else {
    stop("Year must be '2021' or '2022'")
  }

  if (file_path == "") {
    stop(sprintf("USA %s rollcall file not found in package", year))
  }

  cat(sprintf("Loading USA %s rollcall data...\n", year))
  data <- read.csv(file_path, row.names = 1)
  cat(sprintf("Loaded: %d legislators x %d votes\n", nrow(data), ncol(data)))

  return(data)
}

#' Load rollcall matrix from CSV file
#'
#' @description Load any CSV rollcall file (legislators as rows, votes as columns)
#' @param csv_file Character, path to CSV file
#' @return Data.frame with rollcall matrix
#' @export
load_rollcall_csv <- function(csv_file) {

  if (!file.exists(csv_file)) {
    stop(sprintf("File not found: %s", csv_file))
  }

  cat(sprintf("Loading rollcall data from: %s\n", csv_file))
  data <- read.csv(csv_file, row.names = 1)
  cat(sprintf("Loaded: %d legislators x %d votes\n", nrow(data), ncol(data)))

  return(data)
}