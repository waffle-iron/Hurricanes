# Hurricanes 0.0.0.9003

Correct bugs and erroneous data.

## Minor Changes

  * Added `saffir()` to return dataframe of Saffir Simpson Hurricane Scale.

## Bug Fixes

  * `fstadv$Adv` would return NA if additional text after advisory number in header (for example, "...CORRECTED"). Pattern modified to allow optional alphanumeric and punctuation between advisory number and newline character(\n). (#13)
  * `Status` and `Name` were improperly being read due to new types of values in the text product headers. In this case, "POST-TROPICAL CYCLONE" and "REMNANTS OF" which previously were not recognized. These values have been added to list of options as acceptable. Additionally, "REMANTS OF" should be cleaned and produce only "REMNANTS" as `Status` now in returned dataframe. (#14)
  * If `Name` contained hyphen in product header then `Name` would be returned as NA. All east Pacific tropical depressions have a hyphen in the name. Pattern modified to accomodate this. Additionally, some `Status` may contain "SUB" text in `Status`. Pattern modified to accomodate this as well. (#15)

# Hurricanes 0.0.0.9002

## Major new features

### Getting Annual Storm Data

`get_storms` Pass multiple years, basins to get names and archive links of storms.

### Getting Storm Data

`get_storm_data` Pass at least a link to the storm's archive page (from `get_storms`) and a product as listed below to get data from that product. Can pass multiple products, multiple links.

#### Storm Discussions (discus)

Extracts header data and returns content.

#### Forecast/Advisory (fstadv)

The fstadv dataframe now contains the following values:
  * Status
  * Name
  * Adv
  * Date
  * Key
  * Latitude
  * Longitude
  * Wind
  * Gust
  * Pressure
  * Position accuracy
  * Forward direction
  * Forward speed
  * Eye

#### Position Estimate (posest)

Extracts header data and returns content.

#### Public Advisory (public)

Extracts header data and returns content.

#### Strike Probabilities (prblty)

Extracts header data and returns content.

#### Updates (update)

Extracts header data and returns content.

#### Wind Probabilities (wndprb)

Extracts header data and returns content.

