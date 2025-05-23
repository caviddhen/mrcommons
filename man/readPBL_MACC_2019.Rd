% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readPBL_MACC_2019.R
\name{readPBL_MACC_2019}
\alias{readPBL_MACC_2019}
\title{Read in PBL MAC curves from Harmsen_et_al_2019 for different subtypes}
\usage{
readPBL_MACC_2019(subtype)
}
\arguments{
\item{subtype}{data subtype.
"ch4coal","ch4oil","ch4gas","ch4wstl","ch4wsts","ch4rice","ch4animals","ch4anmlwst",
"n2otrans","n2oadac","n2onitac","n2ofert","n2oanwst","n2owaste",
"HFC_tot", "SF6_tot", "PFC_tot" or "baseline_sources"}
}
\value{
magpie object of the PBL_MACC_2019 data
}
\description{
Read in PBL MAC curves from Harmsen_et_al_2019 for different subtypes
}
\seealso{
\code{\link[madrat:readSource]{madrat::readSource()}}
}
\author{
Florian Humpenoeder
}
