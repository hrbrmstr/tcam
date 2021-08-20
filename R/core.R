#' Make a socket connection to a tCam device
#'
#' @param host,port IP/hostname + port; defaults to the device defaults
#' @export
tcam_connect <- function(host = "192.168.4.1", port = 5001) {
  socketConnection(
    host = host,
    port = port,
    open = "a+b"
  )
}

#' Returns a packet with camera status.
#'
#' @param con open socket connection from [tcam_connect()]
#' @export
get_status <- function(con) {

  writeBin(
    object = c(as.raw(0x02), charToRaw('{"cmd":"get_status"}'), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(0.5)

  readBin(
    con = con,
    what = "raw",
    n = 2048L
  ) %>%
    rawToChar() %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}

#' Returns a packet with the camera's current settings.
#'
#' @param con open socket connection from [tcam_connect()]
#' @export
get_config <- function(con) {

  writeBin(
    object = c(as.raw(0x02), charToRaw('{"cmd":"get_config"}'), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(0.5)

  readBin(
    con = con,
    what = "raw",
    n = 2048L
  ) %>%
    rawToChar() %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}

#' Reads and returns specified data from the Lepton's CCI interface.
#'
#' @param con open socket connection from [tcam_connect()]
#' @param command decimal representation of the 16-bit Lepton `COMMAND` register
#'        value. For example, the value `20172` above is `0x4ECC` (RAD Spotmeter
#'        Region of Interest).
#' @param length decimal number of 16-bit words to read (`1-512`).
#' @references [FLIR LEPTON Software Interface Description Document (IDD)](https://www.flir.com/globalassets/imported-assets/document/flir-lepton-software-interface-description-document.pdf)
#' @export
get_lep_cci <- function(con, command, length) {

  stopifnot(((length >= 1) && (length <= 512)))

  list(
    cmd = "get_lep_cci",
    args = list(
      command = as.integer(command),
      length = as.integer(length)
    )
  ) %>%
    jsonlite::toJSON(auto_unbox = TRUE) -> cmd

  Sys.sleep(0.5)

  tmp <- get_status(con)

  Sys.sleep(0.5)

  writeBin(
    object = c(as.raw(0x02), charToRaw(cmd), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(0.5)

  readBin(
    con = con,
    what = "raw",
    n = 2048L
  ) %>%
    rawToChar() %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}

#' Set the camera's clock.
#'
#' @param con open socket connection from [tcam_connect()]
#' @param time `Date` or `POSIXct` object or a character string that
#'        can be coerced to one; defaults to "now".
#' @export
set_time <- function(con, time = Sys.time()) {

  Sys.sleep(0.5)

  tmp <- get_status(con)

  Sys.sleep(0.5)

  time <- as.POSIXlt(as.POSIXct(time[1]))

  list(
    cmd = "set_time",
    args = list(
      sec = as.integer(time$sec),
      min = time$min,
      hour = time$hour,
      dow = time$wday + 1L,
      day = time$mday,
      mon = time$mon + 1L,
      year = time$year + 1900L - 1970L
    )
  ) %>%
    jsonlite::toJSON(auto_unbox = TRUE) -> cmd

  writeBin(
    object = c(as.raw(0x02), charToRaw(cmd), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(0.5)

  readBin(
    con = con,
    what = "raw",
    n = 2048L
  ) %>%
    rawToChar() %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}

# #' Set the camera's Wi-Fi and network configuration.
# #'
# #' The Wi-Fi subsystem is immediately restarted. Which means
# #' `con` is no longer valid and will need to be re-opened. Leave paramaters
# #' as `NULL` if you do not want to change those settings on the tCam.
# #'
# #' @param con open socket connection from [tcam_connect()]
# #' @param ap_ssid Set the AP-mode SSID and also the camera name as reported in the metadata and status objects.
# #' @param ap_pw Set the AP-mode password.
# #' @param ap_ip_addr The camera's IP address when it is in AP mode.
# #' @param flags Set WiFi configuration (see below).
# #' @param sta_ssid Set the client-mode (STA) SSID.
# #' @param sta_pw Set the client-mode (STA) password.
# #' @param sta_ip_addr Set the static IP address to use when the camera as a client and configured to use a static IP.
# #' @param sta_netmask Set the netmask to use when the camera as a client and configured to use a static IP.
# #' @export
# set_wifi <- function(con, ap_ssid = NULL, ap_pw = NULL, ap_ip_addr = NULL,
#                      flags = NULL,
#                      sta_ssid = NULL, sta_pw = NULL, sta_ip_addr = NULL, sta_netmask = NULL) {
#
#   list(
#     ap_ssid = ap_ssid,
#     ap_pw = ap_pw,
#     ap_ip_addr = ap_ip_addr,
#     flags = flags,
#     sta_ssid = sta_ssid,
#     sta_pw = sta_pw,
#     sta_ip_addr = sta_ip_addr,
#     sta_netmask = sta_netmask
#   )
#
#   writeBin(
#     object = c(as.raw(0x02), charToRaw('{"cmd":"get_status"}'), as.raw(0x03)),
#     con = con,
#     useBytes = TRUE
#   ) -> res
#
#   Sys.sleep(0.5)
#
#   readChar(
#     con = con,
#     nchars = 2048L,
#     useBytes = TRUE
#   ) %>%
#     stri_replace_all_regex("\002|\003", "") %>%
#     fparse()
#
# }


#' Returns a packet with metadata, radiometric (or AGC) image data and Lepton telemetry objects.
#'
#' @param con open socket connection from [tcam_connect()]
#' @export
get_image <- function(con) {

  Sys.sleep(0.5)

  tmp <- get_status(con)

  Sys.sleep(0.5)

  writeBin(
    object = c(as.raw(0x02), charToRaw('{"cmd":"get_image"}'), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(1)

  readBin(
    con = con,
    what = "raw",
    n = 65536L
  ) %>%
    rawToChar() %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}

#' Returns a packet with the camera's current WiFi and Network configuration.
#'
#' @param con open socket connection from [tcam_connect()]
#' @export
get_wifi <- function(con) {

  Sys.sleep(0.5)

  tmp <- get_status(con)

  Sys.sleep(0.5)

  writeBin(
    object = c(as.raw(0x02), charToRaw('{"cmd":"get_wifi"}'), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(0.5)

  readBin(
    con = con,
    what = "raw",
    n = 5120L
  ) %>%
    rawToChar() %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}