## convert4iboxplot
## Karl W Broman

# Convert data to JSON format for iboxplot vis
#
# @param dat Data matrix (individuals x variables)
# @param qu Quantiles to plot (All with 0 < qu < 0.5)
# @param orderByMedian If TRUE, reorder individuals by their median
# @param breaks Number of break points in the histogram
# @param digits Number of digits in JSON file; passed to \code{\link[jsonlite]{toJSON}}
#
# @return Character string with the input data in JSON format
#
#' @importFrom jsonlite toJSON
#' @importFrom stats quantile
#' @importFrom graphics hist
#
# @keywords interface
# @seealso \code{\link{iboxplot}}
#
# @examples
# n.ind <- 500
# n.gene <- 10000
# expr <- matrix(rnorm(n.ind * n.gene, (1:n.ind)/n.ind*3), ncol=n.gene)
# dimnames(expr) <- list(paste0("ind", 1:n.ind),
#                        paste0("gene", 1:n.gene))
# geneExpr_as_json <- convert4iboxplot(expr)
convert4iboxplot <-
function(dat, qu = c(0.001, 0.01, 0.1, 0.25), orderByMedian=TRUE,
         breaks=251, digits=4)
{
  if(is.null(rownames(dat)))
    rownames(dat) <- paste0(1:nrow(dat))

  if(orderByMedian)
    dat <- dat[order(apply(dat, 1, median, na.rm=TRUE)),,drop=FALSE]

  # check quantiles
  if(any(qu <= 0)) {
    warning("qu should all be > 0")
    qu <- qu[qu > 0]
  }

  if(any(qu >= 0.5)) {
    warning("qu should all by < 0.5")
    qu <- qu[qu < 0.5]
  }

  qu <- c(qu, 0.5, rev(1-qu))
  quant <- apply(dat, 1, quantile, qu, na.rm=TRUE)

  # counts for histograms
  if(length(breaks) == 1)
    breaks <- seq(min(dat, na.rm=TRUE), max(dat, na.rm=TRUE), length=breaks)

  counts <- apply(dat, 1, function(a) hist(a, breaks=breaks, plot=FALSE)$counts)

  ind <- rownames(dat)

  dimnames(quant) <- dimnames(counts) <- NULL

  # data structure for JSON
  output <- list("ind" = jsonlite::toJSON(ind, na="null"),
                 "qu" = jsonlite::toJSON(qu, na="null"),
                 "breaks" = jsonlite::toJSON(breaks, digits=digits, na="null"),
                 "quant" = jsonlite::toJSON(quant, digits=digits, na="null"),
                 "counts" = jsonlite::toJSON(t(counts)), na="null")
  output <- paste0("{", paste0("\"", names(output), "\" :", output, collapse=","), "}")
  strip_whitespace(output)
}
