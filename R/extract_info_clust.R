#' Helper function for modelsummary
#'
#' Extracts infos from `donut_list` which are clustered
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom data.table transpose
#' @importFrom kableExtra spec_hist
#'
#' @keywords internal
#' @export

extract_info_clust <- function(donut_model,
                               hist = TRUE,
                               ...) {
  rows <- extract_info(donut_model) |>
    mutate(perc_treated = n_treated / n_obs * 100) |>
    mutate(n_treated = paste0(n_treated, " (", round(perc_treated, 2), "%)")) |>
    mutate(n_clust_w_treated = paste0(n_clust, " (", n_clust_treated, ")")) |>
    select(outer, n_treated, n_clust_w_treated) |>
    transpose()
  rows <- cbind(names = c(
    "Outer radius [km]",
    "Num. treated (%)",
    "Num. clusters (treated cl.)"
  ),
  rows)

  if (hist == TRUE) {
    hist_svgs <- lapply(1:length(donut_model),
                        function(x)
                          donut_model[[x]][["clust"]][["clust_size"]]) |>
      spec_hist(
        col = "black",
        border = NA,
        ...
      )
    hists <- data.frame(hist = sapply(1:length(hist_svgs),
                                      function(x)
                                        hist_svgs[[x]][["svg_text"]])) |>
      transpose()
    hists <- cbind(names = "Cluster histogram", hists)

    rows <- rbind(rows, hists)
  }
  return(rows)
}
