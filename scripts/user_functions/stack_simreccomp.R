#' Transforming recurrent and terminal event data into stacked format.
#' 
#' `stack_simreccomp` a dataset with a recurrent and competing events
#' simulates with `simrec::simreccomp()` and turns it into a stacked dataset
#' for further analysis.
#' 
#' @param data 
#'  A `data.frame` created with `simrec::simreccomp()`.
#'  
#' @return 
#'  Returns a `data.table` with at least two rows per observations. 
#'  One row for the start and end time of follow-up for the competing event and 
#'  at least one row for the start and end times of follow-up for the recurrent 
#'  event.
#' 
#' @export

stack_simreccomp <- function(data){
  
  # Get dataset for recurrent events
  temp_re <- data.table::as.data.table(data.table::copy(data))
  temp_re[order(id, stop),
          `:=` (status = data.table::fifelse(status == 2, 0, status),
                re     = 1)]
  
  # Get dataset for competing events
  temp_ce <- data.table::as.data.table(data.table::copy(data))[stop == fu]
  temp_ce[,
          `:=` (start  = 0,
                status = data.table::fifelse(status == 2, 1, 0),
                re     = 0)]
  
  # Combine datasets
  temp_comb <- data.table::rbindlist(list(temp_ce, temp_re))
  temp_comb[, `:=`(ce   = data.table::fifelse(re == 1, 0, 1),
                   stop = data.table::fifelse(stop < 0.1, stop + 0.00001, stop))]
  
  return(temp_comb)
}
