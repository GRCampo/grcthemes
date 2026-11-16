#' Galeria de imagens a partir de arquivos
#'
#' Monta uma galeria (imagem grande + miniaturas com setas) com imagens ja salvas.
#' Use dentro de um chunk; nao precisa de results = "asis".
#'
#' Para plots gerados no proprio chunk, use a opcao `gallery = TRUE`:
#' \preformatted{
#' ```{r, gallery = TRUE, fig.cap = paste("Site", LETTERS[1:5])}
#' for (s in sites) print(ggplot(...))
#' ```
#' }
#'
#' @param files Caminhos das imagens (png, jpg, svg...).
#' @param captions Legendas. Padrao: nome do arquivo sem extensao.
#' @examples
#' \dontrun{
#' grc_gallery(list.files("figs/ndvi", pattern = "png$", full.names = TRUE))
#' }
#' @export
grc_gallery <- function(files, captions = NULL) {
  if (!length(files)) stop("No files given to grc_gallery().", call. = FALSE)
  if (is.null(captions)) captions <- tools::file_path_sans_ext(basename(files))
  if (length(captions) != length(files)) {
    stop("'captions' must have the same length as 'files'.", call. = FALSE)
  }
  missing <- files[!file.exists(files)]
  if (length(missing)) stop("File(s) not found: ", paste(missing, collapse = ", "), call. = FALSE)

  captions <- gsub("([][\\\\])", "\\\\\\1", captions)   # escapa [ ] \ do markdown
  imgs <- sprintf("![%s](<%s>)", captions, files)       # <...> aceita espacos no caminho
  knitr::asis_output(paste(c("", "::: gallery", "", imgs, "", ":::", ""), collapse = "\n\n"))
}

# Hook de chunk: gallery = TRUE envolve a saida do chunk num bloco ::: gallery
.gallery_hook <- function(before, options, envir) {
  if (!isTRUE(options$gallery)) return(NULL)
  if (before) "\n\n::: gallery\n\n" else "\n\n:::\n\n"
}
