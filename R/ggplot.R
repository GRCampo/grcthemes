# ===================================================================
#  ggplot: cores, escalas e tema (versoes genericas, recebem o 'spec'
#  de um tema do registro). Cada tema exporta atalhos com o seu nome,
#  ex.: greenOlive_colors(), scale_colour_greenOlive(), theme_greenOlive().
# ===================================================================

.grc_colors <- function(spec, n = NULL, ...) {
  pal <- spec$palette
  pick <- c(...)
  if (is.character(n)) { pick <- c(n, pick); n <- NULL }   # colors("sand") tambem funciona
  if (length(pick)) {
    bad <- setdiff(pick, names(pal))
    if (length(bad)) stop("Unknown colour(s): ", paste(bad, collapse = ", "),
                          ". Options: ", paste(names(pal), collapse = ", "), call. = FALSE)
    return(unname(pal[pick]))
  }
  if (is.null(n)) return(pal)
  if (n > length(pal)) {
    warning(spec$name, " has ", length(pal), " categorical colours; ", n,
            " requested, colours will repeat. Consider grouping or faceting.", call. = FALSE)
    return(rep_len(unname(pal), n))
  }
  unname(pal[seq_len(n)])
}

.grc_scale_d <- function(spec, ..., reverse = FALSE, aesthetics = "colour") {
  ggplot2::discrete_scale(
    aesthetics = aesthetics,
    palette = function(n) { p <- .grc_colors(spec, n); if (reverse) rev(p) else p },
    ...
  )
}

.grc_scale_c <- function(spec, palette = c("seq", "div"), ..., midpoint = 0,
                         reverse = FALSE, aesthetics = "colour") {
  palette <- match.arg(palette)
  cols <- spec[[palette]]
  if (reverse) cols <- rev(cols)
  if (palette == "div") {
    ggplot2::scale_colour_gradientn(
      colours = cols, aesthetics = aesthetics,
      rescaler = function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
        scales::rescale_mid(x, to, from, midpoint)
      },
      ...
    )
  } else {
    ggplot2::scale_colour_gradientn(colours = cols, aesthetics = aesthetics, ...)
  }
}

.grc_ggtheme <- function(spec, base_size = 12, grid = c("xy", "y", "x", "none"),
                         legend = "bottom", fonts = TRUE) {
  grid <- match.arg(grid)
  p <- spec$plot
  body   <- if (fonts) p$font_body else ""
  title  <- if (fonts) p$font_title else ""
  accent <- if (fonts) p$font_accent else ""
  el <- ggplot2::element_text
  gl <- ggplot2::element_line(colour = p$grid, linewidth = 0.4)
  no <- ggplot2::element_blank()

  ggplot2::theme_minimal(base_size = base_size, base_family = body) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = p$bg, colour = NA),
      panel.background = ggplot2::element_rect(fill = p$bg, colour = NA),
      panel.grid.minor = no,
      panel.grid.major.x = if (grid %in% c("xy", "x")) gl else no,
      panel.grid.major.y = if (grid %in% c("xy", "y")) gl else no,
      text       = el(colour = p$text),
      axis.text  = el(colour = p$muted),
      axis.title = el(colour = p$text),
      plot.title    = el(family = title, face = "bold", colour = p$title,
                         size = ggplot2::rel(1.4), margin = ggplot2::margin(b = 4)),
      plot.subtitle = el(family = accent, face = "italic", colour = p$muted,
                         margin = ggplot2::margin(b = 10)),
      plot.caption  = el(family = accent, face = "italic", colour = p$muted,
                         size = ggplot2::rel(0.8), hjust = 0),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      strip.text       = el(family = title, face = "bold", colour = p$title, hjust = 0),
      strip.background = ggplot2::element_rect(fill = p$strip_bg, colour = NA),
      legend.position  = legend,
      legend.title     = el(face = "bold"),
      plot.margin      = ggplot2::margin(12, 12, 12, 12)
    )
}
