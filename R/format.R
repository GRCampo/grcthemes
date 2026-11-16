# ===================================================================
#  Motor do formato HTML (compartilhado por todos os temas)
#  Layout: header / menu principal (#) / menu lateral (##) + corpo / rodape
# ===================================================================

.grc_format <- function(theme,
                        header_img = NULL,
                        footer_img = NULL,
                        logos = NULL,
                        logo_chip = TRUE,
                        intro_label = "Overview",
                        self_notes = TRUE,
                        footer_author = "Gabriela Romero Campos",
                        code_folding = c("none", "show", "hide"),
                        ggplot_defaults = TRUE,
                        dev = "ragg_png",
                        download_dpi = 300,
                        highlight = "tango",
                        ...) {

  spec <- .grc_theme(theme)
  code_folding <- match.arg(code_folding)
  download_on <- !is.null(download_dpi) && !isFALSE(download_dpi)
  norm <- function(p) normalizePath(p, winslash = "/", mustWork = TRUE)

  # Imagem do usuario > imagem do tema (img/header.png, img/footer.png) > nenhuma
  pick_img <- function(user, default_name) {
    if (!is.null(user)) return(norm(user))
    f <- .grc_path(theme, "img", default_name)
    if (nzchar(f)) norm(f) else NULL
  }
  header_img <- pick_img(header_img, "header.png")
  footer_img <- pick_img(footer_img, "footer.png")

  # Logos, em ordem de prioridade:
  #   1. argumento `logos` (YAML): arquivos OU uma pasta
  #   2. options(grcthemes.logos = ...) (ex.: no .Rprofile): arquivos OU uma pasta
  #   3. pasta logos/ do tema  4. logos de exemplo do pacote (shared/logos)
  # Numa pasta, valem os arquivos logo_*:
  #   com selo  (logo_chip = TRUE)  -> logo_*          (versoes coloridas)
  #   sem selo  (logo_chip = FALSE) -> logo_white_*    (cai p/ coloridas se nao houver)
  if (is.null(logos)) logos <- getOption("grcthemes.logos")
  if (is.null(logos)) {
    logos <- .grc_path(theme, "logos")
    if (!nzchar(logos)) logos <- .grc_path("shared", "logos")
  }
  if (length(logos) == 1 && dir.exists(logos)) {
    all <- list.files(logos, pattern = "^logo_.*\\.(svg|png|jpe?g|webp)$",
                      full.names = TRUE, ignore.case = TRUE)
    is_white <- grepl("^logo_white_", basename(all), ignore.case = TRUE)
    logos <- if (!isTRUE(logo_chip) && any(is_white)) all[is_white] else all[!is_white]
    logos <- logos[order(tolower(basename(logos)))]
  }

  pandoc_args <- c(
    "--variable", paste0("grc_fonts_url=", spec$fonts_url),
    "--variable", paste0("intro_label=", intro_label),
    "--variable", paste0("code_folding=", code_folding),
    "--variable", paste0("footer_stamp=", format(Sys.time(), "%Y-%m-%d %H:%M")),
    # caixas ::: note / ::: self / ::: attention
    "--lua-filter", norm(.grc_path("shared", "callouts.lua")),
    "--metadata", paste0("grc_self_notes=", tolower(isTRUE(self_notes)))
  )
  if (length(footer_author) && nzchar(footer_author)) {
    pandoc_args <- c(pandoc_args, "--variable", paste0("footer_author=", footer_author))
  }
  if (!is.null(header_img)) pandoc_args <- c(pandoc_args, "--variable", paste0("header_img=", header_img))
  if (!is.null(footer_img)) pandoc_args <- c(pandoc_args, "--variable", paste0("footer_img=", footer_img))
  for (lg in logos) pandoc_args <- c(pandoc_args, "--variable", paste0("logos=", norm(lg)))
  if (isTRUE(logo_chip)) pandoc_args <- c(pandoc_args, "--variable", "logo_chip=true")

  version <- as.character(utils::packageVersion("grcthemes"))
  deps <- list(
    htmltools::htmlDependency("grcthemes", version, src = .grc_path("shared"),
                              stylesheet = "grc.css", script = "grc.js"),
    htmltools::htmlDependency(paste0("grcthemes-", theme), version, src = .grc_path(theme),
                              stylesheet = "theme.css")   # depois do grc.css: sobrepoe
  )

  base <- rmarkdown::html_document(
    template = .grc_path("shared", "template.html"),
    theme = NULL,               # sem bootstrap: o CSS e todo nosso
    toc = FALSE,                # a navegacao e feita pelos menus
    section_divs = TRUE,        # cada # e ## vira <div class="section levelN">, usado pelo JS
    highlight = highlight,
    extra_dependencies = deps,
    pandoc_args = pandoc_args,
    ...
  )

  # ggplot: tema + cores do tema durante o knit; restaura o estado anterior no fim
  saved <- NULL
  pre_knit <- function(input, ...) {
    if (!isTRUE(ggplot_defaults)) return(invisible())
    pal <- unname(spec$palette)
    saved <<- list(
      theme = ggplot2::theme_get(),
      opts  = options(
        ggplot2.discrete.colour   = list(pal),
        ggplot2.discrete.fill     = list(pal),
        ggplot2.continuous.colour = function() .grc_scale_c(spec, "seq", aesthetics = "colour"),
        ggplot2.continuous.fill   = function() .grc_scale_c(spec, "seq", aesthetics = "fill")
      )
    )
    ggplot2::theme_set(.grc_ggtheme(spec))
    invisible()
  }
  on_exit <- function() {
    if (is.null(saved)) return(invisible())
    ggplot2::theme_set(saved$theme)
    options(saved$opts)
    saved <<- NULL
    invisible()
  }

  rmarkdown::output_format(
    knitr = rmarkdown::knitr_options(
      # fundo das figuras = fundo da pagina (inclusive R base)
      opts_chunk = list(dev = dev, dev.args = list(bg = spec$plot$bg), download = download_on),
      knit_hooks = c(
        list(gallery = .gallery_hook),                                 # chunk: gallery = TRUE
        if (download_on) list(plot = .download_plot_hook(download_dpi)) # data-dl na <img>
      ),
      opts_hooks = if (download_on) list(download = .download_opts_hook(download_dpi))
    ),
    pandoc = NULL,
    pre_knit = pre_knit,
    on_exit = on_exit,
    base_format = base
  )
}
