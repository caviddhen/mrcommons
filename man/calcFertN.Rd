% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcFertN.R
\name{calcFertN}
\alias{calcFertN}
\title{Calculate Fertilizer of N}
\usage{
calcFertN(
  appliedto = "total",
  cellular = FALSE,
  deposition = "CEDS",
  max_snupe = 0.85
)
}
\arguments{
\item{appliedto}{'total' (default), 'crop' or 'past'}

\item{cellular}{cellular disaggreagation or national values}

\item{deposition}{for disaggregation will be passed on to calcNitrogenBudgetCropland}

\item{max_snupe}{for disaggregation will be passed on to calcNitrogenBudgetCropland}
}
\value{
Fertilizer data for N and corresonding weights as a list of two
MAgPIE objects
}
\description{
Provides FertN data for N.No changes to the content have been done.
}
\examples{
\dontrun{
calcOutput("FertN")
}
}
\seealso{
\code{\link[madrat:calcOutput]{madrat::calcOutput()}}, \code{\link[=readIFA]{readIFA()}},
\code{\link[=convertIFA]{convertIFA()}}, \code{\link[madrat:readSource]{madrat::readSource()}}
}
\author{
Lavinia Baumstark
}
