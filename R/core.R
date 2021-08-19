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

  readChar(
    con = con,
    nchars = 2048L,
    useBytes = TRUE
  ) %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}

#' Returns a packet with metadata, radiometric (or AGC) image data and Lepton telemetry objects.
#'
#' @param con open socket connection from [tcam_connect()]
#' @export
get_image <- function(con) {

  tmp <- get_status(con)

  writeBin(
    object = c(as.raw(0x02), charToRaw('{"cmd":"get_image"}'), as.raw(0x03)),
    con = con,
    useBytes = TRUE
  ) -> res

  Sys.sleep(0.5)

  readChar(
    con = con,
    nchars = 65536L,
    useBytes = TRUE
  ) %>%
    stri_replace_all_regex("\002|\003", "") %>%
    fparse()

}