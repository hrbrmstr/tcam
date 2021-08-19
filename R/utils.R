#' Return a tidy data frame of Lepton radiometric data retrieved with [get_image()]
#'
#' Converts the base64 16-bit coded Kelvin radiometric data to a tidy "XYZ"
#' data frame in Fahrenheit.
#'
#' @param img_data data structure retrieved with [get_image()]
#' @returns data frame of `x`, `y`, and `value`
#' @export
tidy_radiometric <- function(img_data) {

  if (!hasName(img_data, "radiometric")) {
    stop("Data structure does not seem to be tCam radiometric image data.", call.=FALSE)
  }

  openssl::base64_decode(img_data$radiometric) %>%
    readBin(
      what = "integer",
      n = 19200,
      size = 2
    ) %>%
    matrix(
      nrow = 120,
      ncol = 160,
      byrow = TRUE,
      dimnames = list(120:1)
    ) -> m

  as.data.frame(m) %>%
    mutate(y = rownames(m)) %>%
    gather(x, value, -y) %>%
    mutate_at(
      vars(x),
      ~sub("V", "", .)
    ) %>%
    mutate(
      x = as.integer(x),
      y = as.integer(y),
      value = ((value / 100) * 1.8) - 459.67 # convert to degrees F b/c I'm a brutish Murican
    ) -> xdf

  xdf[,c("x", "y", "value")]

}