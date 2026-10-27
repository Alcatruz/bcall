# Two clear blocs of legislators ("l_" and "r_") voting on `m` bills.
two_blocs <- function(n = 20, m = 40, seed = 1) {
  set.seed(seed)
  side <- rep(c(-1, 1), each = n / 2)
  position <- side + stats::rnorm(n, 0, 0.3)
  cutpoints <- stats::rnorm(m, 0, 0.6)
  votes <- sapply(cutpoints, function(k) ifelse(position + stats::rnorm(n, 0, 0.3) > k, 1, -1))
  votes <- as.data.frame(votes)
  rownames(votes) <- c(paste0("l_", 1:(n / 2)), paste0("r_", 1:(n / 2)))
  votes
}

# The rollcall of the README Quick Start.
readme_rollcall <- function() {
  data.frame(
    Vote_01 = c(1, -1, 1, 0, NA),
    Vote_02 = c(1, -1, 1, 1, 1),
    Vote_03 = c(-1, 1, 1, 0, -1),
    row.names = c("Leg_A", "Leg_B", "Leg_C", "Leg_D", "Leg_E")
  )
}
