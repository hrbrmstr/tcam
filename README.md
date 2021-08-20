
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-100%25-lightgrey.svg)
[![R-CMD-check](https://github.com/hrbrmstr/tcam/workflows/R-CMD-check/badge.svg)](https://github.com/hrbrmstr/tcam/actions?query=workflow%3AR-CMD-check)
[![Linux build
Status](https://travis-ci.org/hrbrmstr/tcam.svg?branch=master)](https://travis-ci.org/hrbrmstr/tcam)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/tcam/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/tcam)
![Minimal R
Version](https://img.shields.io/badge/R%3E%3D-3.6.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# tcam

Retrieve Radiometric Image Data from and Configure and Control tCam and
tCam-Mini Thermal Imaging Systems

## Description

The tCam and tCam-Mini
(<https://github.com/danjulio/lepton/tree/master/ESP32>) are two cameras
designed around the ESP32 chipset and provide easy access to radiometric
data from Lepton 3.5 sensors. Tools are provided to configure, control,
and receive radiometric data from tCam systems.

## What’s Inside The Tin

The following functions are implemented:

-   `get_config`: Returns a packet with the camera’s current settings.
-   `get_image`: Returns a packet with metadata, radiometric (or AGC)
    image data and Lepton telemetry objects.
-   `get_lep_cci`: Reads and returns specified data from the Lepton’s
    CCI interface.
-   `get_status`: Returns a packet with camera status.
-   `get_wifi`: Returns a packet with the camera’s current WiFi and
    Network configuration.
-   `set_time`: Set the camera’s clock.
-   `tcam_connect`: Make a socket connection to a tCam device
-   `tidy_radiometric`: Return a tidy data frame of Lepton radiometric
    data retrieved with get_image()

## Installation

``` r
remotes::install_git("https://git.rud.is/hrbrmstr/tcam.git")
# or
remotes::install_gitlab("hrbrmstr/tcam")
# or
remotes::install_github("hrbrmstr/tcam")
```

NOTE: To use the ‘remotes’ install options you will need to have the
[{remotes} package](https://github.com/r-lib/remotes) installed.

## Usage

``` r
library(tcam)
library(ggplot2) # for plotting

# current version
packageVersion("tcam")
## [1] '0.1.0'
```

Open a connection to the tCam:

``` r
con <- tcam_connect()
```

Get the tCam status:

``` r
get_status(con)
## $status
## $status$Camera
## [1] "tCam-Mini-B3CD"
## 
## $status$Model
## [1] 2
## 
## $status$Version
## [1] "1.3"
## 
## $status$Time
## [1] "12:04:24.769"
## 
## $status$Date
## [1] "8/20/21"
```

Take a picture and plot it:

``` r
img <- get_image(con)

ggplot(tidy_radiometric(img)) +
  geom_tile(
    aes(x, y, fill = value),
    color = NA
  ) +
  scale_fill_viridis_c(
    name = "°F",
    option = "magma"
  ) +
  coord_fixed() +
  labs(
    x = NULL, y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x.bottom = element_blank(),
    axis.text.y.left = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
```

<img src="man/figures/README-ex-02-1.png" width="672" />

Done, so we close the connection (kinda important)

``` r
close(con)
```

## tcam Metrics

| Lang | # Files |  (%) | LoC |  (%) | Blank lines |  (%) | # Lines |  (%) |
|:-----|--------:|-----:|----:|-----:|------------:|-----:|--------:|-----:|
| R    |       6 | 0.33 | 174 | 0.38 |          55 | 0.34 |     123 | 0.37 |
| Rmd  |       1 | 0.06 |  34 | 0.07 |          25 | 0.15 |      42 | 0.13 |
| YAML |       2 | 0.11 |  23 | 0.05 |           2 | 0.01 |       2 | 0.01 |
| SUM  |       9 | 0.50 | 231 | 0.50 |          82 | 0.50 |     167 | 0.50 |

clock Package Metrics for tcam

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
