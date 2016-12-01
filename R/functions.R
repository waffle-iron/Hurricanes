#' @title Hurricanes
#' @description Hurricanes is a web-scraping library for R designed to deliver 
#' hurricane data (past and current) into well-organized datasets. With these 
#' datasets you can explore past hurricane tracks, forecasts and structure 
#' elements. 
#' 
#' Text products (Forecast/Advisory, Public Advisory, Discussions and 
#' Probabilities) are only available from 1998 to current. An effort will be 
#' made to add prior data as available.
#' 
#' @section Getting Storms:
#' List all storms that have developed by year and basin. Year must be in a 
#' four-digit format (\%Y) and no earlier than 1998. Basin can be one or both 
#' of Atlantic ("AL") or East Pacific ("EP"). 
#' \describe{
#'   \item{\code{\link{get_storms}}}{List all storms by year, basin}
#' }
#' 
#' @section Getting Storm Data:
#' There are several products available for every storm. Some storms have 
#' extra products depending on their conditions. And there are several ways of 
#' getting this data.
#' 
#' With \code{\link{get_storms}} a dataframe is returned with a variable Link 
#' to each storm's archive page. There are several products available but the 
#' three minimum for each storm are:
#' \describe{
#'   \item{Forecast/Advisory (fstadv)}{Contains current storm information, 
#'     forecast track, wind speed, forecast wind radius and other data. This 
#'     product contains the bulk of detailed information on a storm.}
#'   \item{Storm Discussion (discus)}{Contains discussion text on the current 
#'     structure of the storm, forecast models and past trends.}
#'   \item{Wind Probabilities (wndprb)}{Contains the probability of n-wind 
#'     affecting a certain area within the forecast period.}
#' }
#' 
#' Of the three above only the forecast/advisory (fstadv) products are scraped 
#' in detail. Additional data will be incorporated soon. The other products 
#' only returnthe content of the text product.
#' 
#' When you have a link to a storm's archive page you pass that value (or a 
#' vector of storm links) to \code{\link{get_storm_data}} along with the 
#' product you want to retrieve. There is no default and you must specify at 
#' least one product.
#' 
#' Keep in mind the more products/storms you request the longer it can take to 
#' return results. Given a good internet connection you can get all fstadv 
#' products for one storm in under 1 second
#' 
#' See \code{\link{get_storm_data}} for information on the other products 
#' available. 
#' 
#' Additionally, each product is its own function you can use to return data 
#' for a specific advisory. In other words, if you have a link to a fstadv 
#' product, say for Bonnie, 2016, Adv 6, you can pass that link directly to 
#' \code{\link{fstadv}}
#' 
#' \code{
#'   x <- "http://www.nhc.noaa.gov/archive/2016/al02/al022016.fstadv.006.shtml?"
#'   fstadv(link = x)
#' }
#' 
#' @section Helper Functions:
#' There are a few helper functions available.
#' 
#' \code{\link{toproper}} Most all storm data returned is either mixed-case
#' (aBcDeFg) or all uppercase. \code{\link{toproper}} will turn something like 
#' "TROPICAL DEPRESSION ONE" into "Tropical Depression One".
#' 
#' \code{\link{saffir}} Returns a dataframe of values based on the Saffir 
#' Simpson Hurricane Scale.
#' 
#' @docType package
#' @name Hurricanes
NULL

#' @title .extract_year_archive_link
#' @description Extracts the year from the archive link. 
#' @param link URL of archive page
#' @return year 4-digit numeric
.extract_year_archive_link <- function(link) {
  
  # Year is listed in link towards the end surrounded by slashes. 
  year <- as.numeric(stringr::str_match(link, '/([:digit:]{4})/')[,2])
  
  return(year)  
  
}

#' @title get_nhc_link
#' @description Return root link of NHC archive pages.
#' @param withTrailingSlash True, by default. False returns URL without 
#' trailing slash.
#' @export
get_nhc_link <- function(withTrailingSlash = TRUE) {
  if(withTrailingSlash)
    return('http://www.nhc.noaa.gov/')
  return('http://www.nhc.noaa.gov')
}

#' @title month_str_to_num
#' @description Convert three-character month abbreviation to integer
#' @param m Month abbreviated (SEP, OCT, etc.)
#' @return numeric 1-12
month_str_to_num <- function(m) {
  
  if(is.character(m) & length(m) != 3) {
    m <- which(month.abb == toproper(m))
    return(m)
  } else {
    stop('Expected three-character string.')
  }
  
}

#' @title saffir
#' @description Returns dataframe of Saffir Simpson Hurricane Scale.
#' @details Classification of storms are based on wind speed. The 
#' \href{http://www.nhc.noaa.gov/aboutsshws.php}{Saffir-Simpson Hurricane Scale} 
#' is technically defined for classifying hurricanes but this will classify 
#' tropical storms and depressions as well.
#' 
#' Subtropical or Extratropical storms should not use this measure but rather 
#' use the status contained in the header of the text product. This function 
#' should be used for summaries only.
#' @return Dataframe of Saffir Simpson Hurricane Scale.
#' @export
saffir <- function() {

  df <- data.frame("Abbr" = c("TD", "TS", 1, 2, 3, 4, 5), 
                   "Long" = c("Tropical Depression", 
                              "Tropical Storm", 
                              "Category 1", 
                              "Category 2", 
                              "Category 3", 
                              "Category 4", 
                              "Category 5"), 
                   "MaxWind" = c(38, 64, 83, 95, 113, 134, NA), 
                   "Damage" = c(NA, 
                                NA, 
                                "Minimal", 
                                "Moderate", 
                                "Extensive", 
                                "Extreme", 
                                "Catastrophic"))
  return(df)
}

#' @title .status
#' @description Test URL status. 
#' @details Return URL if status is 'OK'. Otherwise, return NA and print 
#' failed URL.
#' @param u URL to test
#' @return URL if result is 'OK', otherwise, NA. 
.status <- function(u) {
  stat = httr::http_status(httr::GET(u))
  if(stat$reason == 'OK') {
    return(u)
  } else {
    warning(sprintf("URL unavailable. %s", u))
    return(NA)
  }
}

#' @title toproper
#' @description Convert a string to proper case. 
#' @details Taken from \code{\link{chartr}} examples in base R. Will take a 
#'   phrase or, in the case of this project, full name and status of a cyclone, 
#'   e.g., "TROPICAL STORM ALEX" and return "Tropical Storm Alex".
#' @param s Word or phrase to translate.
#' @param strict TRUE by default. Will convert all upper case characters to 
#'   lower case. If FALSE, no conversion will be done.
#' @examples 
#' toproper("TROPICAL STORM ALEX")
#' toproper("TROPICAL STORM ALEX", strict = FALSE)
#' @export
toproper <- function(s, strict = TRUE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

#' @title .validate_year
#' @description Test if year is 4-digit numeric. 
#' @return numeric year(s)
#' @examples 
#' validate_year(1990)
#' validate_year(1991:1995)
#' validate_year(c(1996, 1997, 1998))
#' validate_year(c('1999', '2000'))
#' validate_year(list(2001, '2002', '2003'))
#' \dontrun{
#' validate_year(199) # Generates error}
.validate_year <- function(y) {
  y <- as.numeric(y)
  if(all(is.na(y)))
    stop('Year must be numeric.')
  if(any(nchar(y) != 4))
    stop('Year must be 4 digits.')
  return(y)
}
