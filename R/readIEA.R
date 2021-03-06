#' Read IEA
#' 
#' Read-in an IEA csv file as magpie object
#' 
#' 
#' @param subtype data subtype. Either "EnergyBalances", "CHPreport" or "Emissions")
#' @return magpie object of the IEA
#' @author Anastasis Giannousakis, Lavinia Baumstark, Renato Rodrigues
#' @seealso \code{\link{readSource}}
#' @examples
#' 
#' \dontrun{ a <- readSource(type="IEA",subtype="EnergyBalances")
#' }
#' 
#' @importFrom data.table fread
#' @importFrom madrat toolCountry2isocode
#' 
readIEA <- function(subtype) {
  
  if (subtype == "EnergyBalances") { #IEA energy balances until 2015 (estimated 2016) (data updated in February, 2018)
    data <- fread("ExtendedEnergyBalances.csv", sep=";", stringsAsFactors = FALSE, colClasses = c("character", "character", "character", "numeric", "character"), showProgress = FALSE, na.strings = c("x",".."), skip=2, col.names = c("COUNTRY","PRODUCT","FLOW","TIME","ktoe"))
    # converting IEA country names to ISO codes
    data$COUNTRY<-toolCountry2isocode(data$COUNTRY,warn=F,type="IEA")
    # removing NAs and converting data to numeric type
    data<-data[!is.na(data$ktoe),]
    data$ktoe<-suppressWarnings(as.numeric(data$ktoe))
    # creating MAgPIE IEA energy balances object
    mdata<-as.magpie(data,datacol=dim(data)[2], spatial=which(colnames(data)=="COUNTRY"), temporal=which(colnames(data)=="TIME"))
  } else if (subtype== "Emissions") {
    data <- read.csv("emissions2013.csv")
    data$COUNTRY<-toolCountry2isocode(data$COUNTRY,warn=F,type="IEA")
    data<-data[!is.na(data$COUNTRY),]
    data$TIME<-paste("y",data$TIME,sep="")
    if (names(data)[[5]]=="MtCO2")  data<-data[!is.na(data$MtCO2),]
    if (names(data)[[5]]=="MtCO2")  data$MtCO2<-suppressWarnings(as.numeric(data$MtCO2))
    mdata<-as.magpie(data,datacol=dim(data)[2])
  } else if (subtype== "CHPreport") {
    data <- read.csv("CHPdata.csv", sep=";",skip=4)
    data$CountryName <- NULL
    mdata <- as.magpie(data,datacol=2)
    getNames(mdata) <- "chp share"
  }else {
    stop("Not a valid subtype!")
  } 
  
  return(mdata)
}  
