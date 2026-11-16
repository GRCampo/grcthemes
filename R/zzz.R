# ragg e usado pelo knitr pelo nome do device ("ragg_png"); declarado aqui para o R CMD check
#' @importFrom ragg agg_png
NULL

# Ao carregar o pacote: registra as fontes de todos os temas no systemfonts
# (usadas pelo device ragg nos plots), sem precisar instalar nada no sistema.
.onLoad <- function(libname, pkgname) {
  for (theme in names(.grc_themes)) {
    for (family in names(.grc_themes[[theme]]$fonts)) {
      files <- .grc_themes[[theme]]$fonts[[family]]
      f <- function(slot, fallback) {
        x <- if (!is.na(files[slot])) files[[slot]] else files[[fallback]]
        system.file("themes", theme, "fonts", x, package = pkgname)
      }
      try(systemfonts::register_font(
        family,
        plain = f("plain", "plain"), bold = f("bold", "plain"),
        italic = f("italic", "plain"), bolditalic = f("bolditalic", "bold")
      ), silent = TRUE)
    }
  }

  # Com dois devices por chunk (botao de download), o knitr grava o plot num pdf
  # "nulo" antes de redesenhar no ragg. Esse pdf nao conhece as fontes dos temas e
  # geraria avisos; registramos apelidos (so afeta esse rascunho, nao as figuras).
  try({
    families <- unique(unlist(lapply(.grc_themes, function(t) names(t$fonts))))
    new <- setdiff(families, names(grDevices::pdfFonts()))
    if (length(new)) {
      alias <- stats::setNames(rep(list(grDevices::pdfFonts()$Helvetica), length(new)), new)
      do.call(grDevices::pdfFonts, alias)
      do.call(grDevices::postscriptFonts, alias)
    }
  }, silent = TRUE)
}
