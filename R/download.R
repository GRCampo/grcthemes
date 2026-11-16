# ===================================================================
#  Botao de download em alta resolucao para cada figura
#
#  1. opts hook "download": cada plot tambem e salvo por um 2o device
#     (ragg_png, extensao .hires.png) com dpi = download_dpi / fig.retina
#     (o knitr multiplica o dpi de todos os devices pelo fig.retina).
#  2. plot hook: embute o .hires.png como data URI no atributo data-dl
#     da tag <img>. O JS (grc.js) cria o botao de camera.
#  Desligar num chunk: download = FALSE.
# ===================================================================

.download_opts_hook <- function(download_dpi) {
  force(download_dpi)
  function(options) {
    if (!isTRUE(options$download) || length(options$dev) != 1) return(options)
    raster <- c("ragg_png", "png", "CairoPNG", "jpeg", "ragg_jpeg")
    if (!options$dev %in% raster) return(options)        # svg/pdf: ja sao vetoriais
    retina <- if (is.numeric(options$fig.retina)) options$fig.retina else 1
    first_ext <- if (length(options$fig.ext)) options$fig.ext[1] else
      if (grepl("jpeg", options$dev)) "jpeg" else "png"
    options$dev     <- c(options$dev, "ragg_png")
    options$fig.ext <- c(first_ext, "hires.png")
    options$dpi     <- c(options$dpi[1], download_dpi / retina)
    options
  }
}

.download_plot_hook <- function(download_dpi) {
  force(download_dpi)
  function(x, options) {
    out <- knitr::hook_plot_md(x, options)
    if (!isTRUE(options$download)) return(out)
    hires <- sub("\\.[^.]+$", ".hires.png", x)
    if (!file.exists(hires)) return(out)
    name <- paste0(sub("\\.hires\\.png$", "", basename(hires)), "_", download_dpi, "dpi.png")
    attrs <- sprintf('<img data-dl="%s" data-dl-name="%s" data-dl-dpi="%s" ',
                     knitr::image_uri(hires), name, download_dpi)
    sub("<img ", attrs, out, fixed = TRUE)
  }
}
