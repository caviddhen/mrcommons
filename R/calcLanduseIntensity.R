#' @title calcLanduseIntensity
#'
#' @description This function prepares total tau values for use. As the source data already
#'              provides all required information this function purely removes unrequired
#'              data and moves the xref values to the weighting object which is required for
#'              aggregation.
#'
#' @param rescale  TRUE (default), if Tau should be rescaled in a way, that 2010 is always 1
#' @param sectoral "kcr" (default) for MAgPIE crop items and "lpj" for LPJmL crop items, "pasture" for pasture
#' @return Total tau data and corresponding weights as a list of two MAgPIE
#' objects
#' @author Benjamin Leon Bodirsky, Kristine Karstens, Felicitas Beier
#' @seealso [madrat::calcTauTotal()], [madrat::readTau()],
#' [madrat::convertTau()]
#' @examples
#' \dontrun{
#' calcOutput("LanduseIntensity")
#' }
#'
#' @importFrom madrat toolAggregate

calcLanduseIntensity <- function(sectoral = "kcr", rescale = TRUE) {

  selectyears <- findset("past")

  if (sectoral %in% c("kcr", "lpj")) {
    # Mappings
    cropsMAgPIE  <- findset("kcr")
    mag2lpj      <- toolGetMapping(type = "sectoral", name = "MAgPIE_LPJmL.csv", where = "mappingfolder")
    mag2lpj      <- mag2lpj[mag2lpj$MAgPIE %in% cropsMAgPIE, ]
    cropsLPJmL   <- levels(droplevels(factor(mag2lpj$LPJmL)))

    # Load LPJ yields and area on cell level
    yieldsLPJmL  <- collapseNames(calcOutput("LPJmL_new", version = "ggcmi_phase3_nchecks_9ca735cb",
                                             climatetype = "GSWP3-W5E5:historical", subtype = "harvest",
                                             stage = "smoothed", aggregate = FALSE)[, selectyears, cropsLPJmL])

    if (sectoral == "kcr") {
      yieldsLPJmL   <- toolAggregate(yieldsLPJmL, rel = mag2lpj,
                                     from = "LPJmL", to = "MAgPIE", dim = 3.1)
    }

    cropareaLPJmL   <- calcOutput("Croparea", sectoral = sectoral, physical = TRUE,
                                  cellular = TRUE, cells = "lpjcell",
                                  irrigation = TRUE, aggregate = FALSE)

    productionLPJmL <- yieldsLPJmL * cropareaLPJmL
    # Aggregate to countries and across irrigation dimension
    productionLPJmL <- dimSums(productionLPJmL, dim = c(1.1, 1.2, 3.2))

    # Load FAO data and caluculate FAO yields on country level
    productionFAO   <- collapseNames(calcOutput("FAOmassbalance",
                                                aggregate = FALSE)[, , "production"][, , "dm"][, , cropsMAgPIE])

    if (sectoral == "lpj") {
      productionFAO <- toolAggregate(productionFAO, rel = mag2lpj,
                                     from = "MAgPIE", to = "LPJmL", dim = 3.1)
    }

    # Getting overlapping countries
    regions          <- intersect(getItems(productionLPJmL, dim = 1.1),
                                  getItems(productionFAO, dim = 1.1))
    productionLPJmL  <- productionLPJmL[regions, , ]
    productionFAO    <- productionFAO[regions, , ]

    # Calculate TAU as ratio of FAO to LPJmL yields
    tau              <- productionFAO / productionLPJmL
    tau[is.na(tau)]  <- 0
    tau[tau == Inf]  <- 0

    # Aggregate to countries and across irrigation dimension
    cropareaCountry  <- dimSums(cropareaLPJmL, dim = c(1.1, 1.2, 3.1))

    # rescale such that average in 2010 is 1
    if (rescale) {
      rescale2010   <- toolNAreplace(x = tau[, "y2010", ],
                                     weight = cropareaCountry[getItems(tau, dim = 1.1), "y2010", ])
      rescaleWeight <- dimSums(rescale2010$x * rescale2010$weight,
                               dim = 1) / dimSums(rescale2010$weight,
                                                  dim = 1)
      tau           <- tau / setYears(rescaleWeight, NULL)
      tau[is.na(tau)]  <- 0
    }

    # calculate TAU aggregated over all croptypes
    kcr2all <- matrix(c(cropsMAgPIE, rep("all", length(cropsMAgPIE))),
                      ncol = 2,
                      dimnames = list(NULL, c("kcr", "all")))
    tauall  <- toolAggregate(tau, rel = kcr2all, weight = cropareaCountry + 10^(-10), from = "kcr", to = "all", dim = 3)

    x      <- mbind(tau, setNames(tauall, "all"))
    weight <- cropareaCountry
    weight <- mbind(weight, setNames(dimSums(weight, dim = 3.1, na.rm = TRUE), "all"))
    out    <- toolNAreplace(x = x, weight = weight)
    x      <- toolCountryFill(out$x, fill = 0)
    weight <- toolCountryFill(out$weight, fill = 0)
    #  ?Old comment: if only one indicator is required over all crops, I suggest a weighting over area harvested

  } else if (sectoral == "pasture") {

    # Load LPJ yields and area on cell level
    yieldsLPJmL           <- calcOutput("LPJmL_new", version = "ggcmi_phase3_nchecks_9ca735cb",
                                        climatetype = "GSWP3-W5E5:historical", subtype = "harvest", stage = "smoothed",
                                        aggregate = FALSE, years = selectyears)[, , "mgrass.rainfed"]
    pastareaMAgPIE        <- calcOutput("LanduseInitialisation", cellular = TRUE, cells = "lpjcell",
                                        aggregate = FALSE)[, , "past"]
    getNames(yieldsLPJmL) <- getNames(pastareaMAgPIE) <- "pasture"

    productionLPJmL  <- yieldsLPJmL * pastareaMAgPIE
    # Aggregate to country values
    productionLPJmL  <- dimSums(productionLPJmL, dim = c("x", "y"))

    # Load FAO data and caluculate FAO yields on country level
    productionFAO    <- collapseNames(calcOutput("FAOmassbalance",
                                                 aggregate = FALSE)[, , "production"][, , "dm"][, , "pasture"])

    # Getting overlapping countries
    regions          <- intersect(getItems(productionLPJmL, dim = 1.1),
                                  getItems(productionFAO, dim = 1.1))
    productionLPJmL  <- productionLPJmL[regions, , ]
    productionFAO    <- productionFAO[regions, , ]

    # Calculate TAU as ratio of FAO to LPJmL yields
    tau              <- productionFAO / productionLPJmL
    tau[is.na(tau)]  <- 0
    tau[tau == Inf]  <- 0

    # Aggregate to country data
    pastareaCountry  <- dimSums(pastareaMAgPIE, dim = c("x", "y"))

    # rescale such that average in 2010 is 1
    if (rescale) {
      rescale2010   <- toolNAreplace(x = tau[, "y2010", ],
                                     weight = pastareaCountry[getItems(tau, dim = 1.1), "y2010", ])
      rescaleWeight <- dimSums(rescale2010$x * rescale2010$weight, dim = 1) / dimSums(rescale2010$weight, dim = 1)
      tau           <- tau / setYears(rescaleWeight, NULL)
    }

    x      <- tau
    weight <- pastareaCountry[getItems(tau, dim = 1.1), getYears(tau), ]
    out    <- toolNAreplace(x = x, weight = weight)
    x      <- toolCountryFill(out$x, fill = 0)
    weight <- toolCountryFill(out$weight, fill = 0)

  } else {
    stop("selected sectoral setting in calcLanduseIntensity not possible (for now)!")
  }

  return(list(x           = x,
              weight      = weight,
              unit        = "",
              description = "FAO production divided by LPJml yield
                             times LUH areas for MAgPIE representative crops and pasture",
              note        = c("")))
}
