context("Test Forecast/Advisory Scraping.")

# 1998, Tropical Storm Alex, Advisory 1
al011998.01.url <- "http://www.nhc.noaa.gov/archive/1998/archive/mar/MAL0198.001"
al011998.01 <- fstadv(link = al011998.01.url, display_link = FALSE)

test_that('Dataframe Column Names', {
  expect_named(al011998.01, c("Status", "Name", "Adv", "Date", "Key", "Lat", 
                           "Lon", "Wind", "Gust", "Pressure", "PosAcc", 
                           "FwdDir", "FwdSpeed", "Eye")) 
})

test_that("Status.", {
  expect_identical(al011998.01 %>% .$Status, "TROPICAL DEPRESSION")
})

test_that("Name.", {
  expect_identical(al011998.01 %>% .$Name, "ONE")
})

# Advisory returns character because intermediate advisories have numbers like 1A, 2A, etc.
test_that("Adv.", {
  expect_identical(al011998.01 %>% .$Adv, "1")
})

test_that("Date.", {
  expect_equal(al011998.01 %>% .$Date, as.POSIXct("1998-07-27 15:00:00", tz = "UTC"))
})

test_that("Key.", {
  expect_identical(al011998.01 %>% .$Key, "AL011998")
})

test_that("Lat.", {
  expect_equal(al011998.01 %>% .$Lat, 11.5)
})

test_that("Lon.", {
  expect_equal(al011998.01 %>% .$Lon, -27.0)
})

test_that("Wind.", {
  expect_equal(al011998.01 %>% .$Wind, 25)
})

test_that("Gust.", {
  expect_equal(al011998.01 %>% .$Gust, 35)
})

test_that("Pressure.", {
  expect_equal(al011998.01 %>% .$Pressure, 1008)
})

test_that("PosAcc.", {
  expect_equal(al011998.01 %>% .$PosAcc, 50)
})

test_that("FwdDir.", {
  expect_equal(al011998.01 %>% .$FwdDir, 280)
})

test_that("FwdSpeed.", {
  expect_equal(al011998.01 %>% .$FwdSpeed, 20)
})

test_that("Eye.", {
  expect_equal(al011998.01 %>% .$Eye, NA_integer_)
})
