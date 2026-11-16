# ===================================================================
#  Registro de temas
#  -----------------------------------------------------------------
#  Cada tema = uma entrada nesta lista + uma pasta inst/themes/<nome>/
#  com theme.css (cores e fontes) e fonts/ (arquivos .ttf para os plots).
#  Passo a passo para criar um tema novo: veja o README.
# ===================================================================

.grc_themes <- list(

  GRC_greenOlive = list(
    # Fontes do HTML (Google Fonts)
    fonts_url = paste0(
      "https://fonts.googleapis.com/css2?",
      "family=League+Spartan:wght@500;600;700",
      "&family=Libre+Baskerville:ital,wght@0,400;0,700;1,400",
      "&family=Lato:ital,wght@0,400;0,700;1,400",
      "&display=swap"
    ),
    # Fontes dos plots (arquivos em inst/themes/GRC_greenOlive/fonts/)
    fonts = list(
      "Lato" = c(plain = "Lato-Regular.ttf", bold = "Lato-Bold.ttf",
                 italic = "Lato-Italic.ttf", bolditalic = "Lato-BoldItalic.ttf"),
      "League Spartan" = c(plain = "LeagueSpartan-Regular.ttf", bold = "LeagueSpartan-Bold.ttf"),
      "Libre Baskerville" = c(plain = "LibreBaskerville-Regular.ttf", bold = "LibreBaskerville-Bold.ttf",
                              italic = "LibreBaskerville-Italic.ttf",
                              bolditalic = "LibreBaskerville-BoldItalic.ttf")
    ),
    # Tema ggplot
    plot = list(
      font_body = "Lato", font_title = "League Spartan", font_accent = "Libre Baskerville",
      bg = "#FFFCF6", text = "#2F2B25", muted = "#6F6A5C", grid = "#E8DFCC",
      title = "#3F4A33", strip_bg = "#EFE6D2"
    ),
    # Paleta categorica: 8 cores, testada para daltonismo (deuteranopia/protanopia)
    palette = c(
      olive = "#5E6E3F", peach = "#E39A70", sand = "#E0CFA6", blue = "#6A8FB0",
      plum  = "#5A3A52", rose  = "#E7B9C6", dark = "#1F2A1A", grey = "#8C8C8C"
    ),
    # Escalas continuas
    seq = c("#F3ECDD", "#E0CFA6", "#A9B77E", "#7C8B55", "#4F5D36", "#2C3523"),          # creme -> oliva
    div = c("#2F4B66", "#6A8FB0", "#B7CADB", "#F3ECDD", "#EDC2A6", "#C9774C", "#7E3F22") # azul - creme - terracota
  )

)

#' Temas disponiveis no pacote
#'
#' @return Vetor com os nomes dos temas (use como `output: grcthemes::<nome>`).
#' @examples
#' grc_themes()
#' @export
grc_themes <- function() names(.grc_themes)

.grc_theme <- function(name) {
  spec <- .grc_themes[[name]]
  if (is.null(spec)) stop("Unknown theme '", name, "'. Available: ",
                          paste(names(.grc_themes), collapse = ", "), call. = FALSE)
  spec$name <- name
  spec
}

# Caminho dentro de inst/themes/
.grc_path <- function(...) system.file("themes", ..., package = "grcthemes")
