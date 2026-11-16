# ===================================================================
#  Tema GRC_greenOlive: formato R Markdown + atalhos de ggplot
#  Cores e fontes do HTML: inst/themes/GRC_greenOlive/theme.css
#  Cores e fontes dos plots: R/themes.R
# ===================================================================

#' GRC_greenOlive: HTML report (dark olive, peach and sand)
#'
#' Use in the YAML header: `output: grcthemes::GRC_greenOlive`.
#' Layout: fixed header, main menu built from `#` headings, side menu built
#' from the `##` headings of the active section, body and fixed footer.
#'
#' @param header_img Background image for the header. NULL = theme default (none).
#' @param footer_img Background image for the footer. NULL = theme default (none).
#' @param logos Logos shown on the right of the header: image paths (in order) or
#'   a folder with `logo_*` files (colour) and `logo_white_*` files (white).
#'   NULL = `getOption("grcthemes.logos")` if set, otherwise two placeholder
#'   logos; `character(0)` = no logos. Tip: put
#'   `options(grcthemes.logos = "path/to/my/logos")` in your `.Rprofile`.
#' @param logo_chip TRUE puts logos on a light rounded badge (keeps original colours);
#'   FALSE shows the white versions directly on the header.
#' @param intro_label Side-menu label for text placed before the first `##` of a section.
#' @param self_notes FALSE removes every `::: self` box from the HTML (version to share).
#' @param footer_author Name in the footer. `""` shows only the update time.
#' @param code_folding "none", "show" or "hide" (as in html_document). Per chunk:
#'   `class.source = "fold-show"` or `"fold-hide"`.
#' @param ggplot_defaults TRUE applies theme_greenOlive() and the theme colours to all ggplots.
#' @param dev knitr graphics device. "ragg_png" is required for the theme fonts in plots.
#' @param download_dpi Resolution of the PNG downloaded by the camera button on each figure.
#'   NULL removes the buttons (smaller HTML). Per chunk: `download = FALSE`.
#' @param highlight Pandoc syntax highlighting style.
#' @param ... Passed to rmarkdown::html_document().
#' @export
GRC_greenOlive <- function(header_img = NULL, footer_img = NULL, logos = NULL, logo_chip = TRUE,
                           intro_label = "Overview", self_notes = TRUE,
                           footer_author = "Gabriela Romero Campos",
                           code_folding = c("none", "show", "hide"),
                           ggplot_defaults = TRUE, dev = "ragg_png", download_dpi = 300,
                           highlight = "tango", ...) {
  .grc_format("GRC_greenOlive",
              header_img = header_img, footer_img = footer_img, logos = logos,
              logo_chip = logo_chip, intro_label = intro_label, self_notes = self_notes,
              footer_author = footer_author, code_folding = match.arg(code_folding),
              ggplot_defaults = ggplot_defaults, dev = dev, download_dpi = download_dpi,
              highlight = highlight, ...)
}

#' greenOlive colours
#'
#' `greenOlive_palette`: the 8 categorical colours (checked for colour blindness).
#' `greenOlive_colors()`: hex codes by number (`greenOlive_colors(3)`) or name
#' (`greenOlive_colors("olive", "grey")`); with no arguments, the named palette.
#'
#' @param n Number of colours, or a colour name.
#' @param ... More colour names.
#' @export
greenOlive_colors <- function(n = NULL, ...) .grc_colors(.grc_theme("GRC_greenOlive"), n, ...)

#' @rdname greenOlive_colors
#' @export
greenOlive_palette <- .grc_themes$GRC_greenOlive$palette

#' greenOlive scales for ggplot2
#'
#' Discrete: `scale_colour_greenOlive()`, `scale_fill_greenOlive()` (up to 8 groups).
#' Continuous: `scale_colour_greenOlive_c()`, `scale_fill_greenOlive_c()` with
#' `palette = "seq"` (cream to dark olive, e.g. NDVI) or `"div"` (blue - cream -
#' terracotta, e.g. differences; set `midpoint`).
#'
#' @param ... Passed to the ggplot2 scale.
#' @param palette "seq" or "div".
#' @param midpoint Centre of the diverging scale.
#' @param reverse Reverse colour order.
#' @param aesthetics Aesthetics affected.
#' @export
scale_colour_greenOlive <- function(..., reverse = FALSE, aesthetics = "colour") {
  .grc_scale_d(.grc_theme("GRC_greenOlive"), ..., reverse = reverse, aesthetics = aesthetics)
}

#' @rdname scale_colour_greenOlive
#' @export
scale_color_greenOlive <- scale_colour_greenOlive

#' @rdname scale_colour_greenOlive
#' @export
scale_fill_greenOlive <- function(..., reverse = FALSE, aesthetics = "fill") {
  .grc_scale_d(.grc_theme("GRC_greenOlive"), ..., reverse = reverse, aesthetics = aesthetics)
}

#' @rdname scale_colour_greenOlive
#' @export
scale_colour_greenOlive_c <- function(palette = c("seq", "div"), ..., midpoint = 0,
                                      reverse = FALSE, aesthetics = "colour") {
  .grc_scale_c(.grc_theme("GRC_greenOlive"), match.arg(palette), ..., midpoint = midpoint,
               reverse = reverse, aesthetics = aesthetics)
}

#' @rdname scale_colour_greenOlive
#' @export
scale_color_greenOlive_c <- scale_colour_greenOlive_c

#' @rdname scale_colour_greenOlive
#' @export
scale_fill_greenOlive_c <- function(palette = c("seq", "div"), ..., midpoint = 0,
                                    reverse = FALSE, aesthetics = "fill") {
  .grc_scale_c(.grc_theme("GRC_greenOlive"), match.arg(palette), ..., midpoint = midpoint,
               reverse = reverse, aesthetics = aesthetics)
}

#' greenOlive ggplot2 theme
#'
#' Cream background, League Spartan titles, Libre Baskerville italic subtitle and
#' caption, Lato text. Fonts ship with the package and work with the ragg device
#' (default inside the report; in RStudio: Tools > Global Options > General >
#' Graphics > Backend: AGG). Use `fonts = FALSE` on devices without support.
#'
#' @param base_size Base font size.
#' @param grid Grid lines: "xy", "y", "x" or "none".
#' @param legend Legend position.
#' @param fonts Use the theme fonts.
#' @export
theme_greenOlive <- function(base_size = 12, grid = c("xy", "y", "x", "none"),
                             legend = "bottom", fonts = TRUE) {
  .grc_ggtheme(.grc_theme("GRC_greenOlive"), base_size = base_size,
               grid = match.arg(grid), legend = legend, fonts = fonts)
}
