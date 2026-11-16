# grcthemes 0.1.0

* First theme: `GRC_greenOlive` (dark olive, peach and sand; League Spartan,
  Libre Baskerville and Lato).
* Layout with fixed header (title + logos), main menu from `#`,
  side menu from `##`, fixed footer with author and last update time.
* Callout boxes `::: note`, `::: self` (removable with `self_notes: false`)
  and `::: attention`.
* Code folding (`code_folding: show/hide`, `fold-show`/`fold-hide`).
* Image galleries (`gallery = TRUE`, `::: gallery`, `grc_gallery()`).
* Camera button on every figure to download a 300 dpi PNG.
* ggplot2 theme, 8-colour palette (colour-blind checked), discrete and
  continuous (sequential and diverging) scales, applied automatically.
* Placeholder logos in the package; your own logos via the `logos` option
  (files or a folder) or `options(grcthemes.logos = "folder")` in `.Rprofile`.
