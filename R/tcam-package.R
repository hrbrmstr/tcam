#' Retrieve Radiometric Image Data from and Configure and Control tCam and tCam-Mini
#' Thermal Imaging Systems
#'
#' The tCam and tCam-Mini (<https://github.com/danjulio/lepton/tree/master/ESP32>)
#' are two cameras designed around the ESP32 chipset and provide easy access to
#' radiometric data from Lepton 3.5 sensors. Tools are provided to configure, control,
#' and receive radiometric data from tCam systems.
#'
#' @md
#' @name tcam
#' @keywords internal
#' @author Bob Rudis (bob@@rud.is)
#' @importFrom RcppSimdJson fparse
#' @importFrom openssl base64_decode
#' @importFrom tidyr gather
#' @importFrom dplyr mutate mutate_at
#' @importFrom stringi stri_replace_all_regex
#' @importFrom utils hasName
"_PACKAGE"
