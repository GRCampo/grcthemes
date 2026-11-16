# grcthemes

R Markdown HTML themes with a fixed header, a main menu built from `#`
headings, a side menu built from the `##` headings of the active section, and
a fixed footer. Each theme ships with a matching ggplot2 theme and colour
scales.

| Theme | Look |
|---|---|
| `GRC_greenOlive` | dark olive, peach and sand · League Spartan / Libre Baskerville / Lato |

## Install

```r
# from GitHub
# install.packages("remotes")
remotes::install_github("GRCampo/grcthemes")

# or from a local copy of this folder
install.packages("path/to/grcthemes", repos = NULL, type = "source")
```

Dependencies (installed automatically): rmarkdown, knitr, htmltools, ggplot2,
scales, systemfonts, ragg. Optional: plotly.

## Use

```yaml
---
title: "My report"
output:
  grcthemes::GRC_greenOlive:
    code_folding: show
---
```

Or in RStudio: *File > New File > R Markdown > From Template* and pick

- **GRC greenOlive - guide**: every feature, working, with the syntax next to it.
  Start here.
- **GRC greenOlive - blank**: empty report.

Rendering needs internet once (the page fonts come from Google Fonts and are
embedded in the HTML); the resulting file works offline.

## Features

- **Navigation**: `#` = main menu tab, `##` = side menu page, one page shown at a
  time; links, back/forward and reload keep the position.
- **Header and footer**: title, subtitle and your logos (see below); footer with the
  author and the last render time.
- **Callouts**: `::: note`, `::: self` (removed with `self_notes: false`),
  `::: attention`, custom titles with `{.attention title="..."}`.
- **Code folding**: `code_folding: show | hide`, per chunk
  `class.source = "fold-hide" | "fold-show"`, plus a "show/hide all" button.
- **Galleries**: chunk option `gallery = TRUE`, a `::: gallery` block, or
  `grc_gallery(files)`.
- **Download**: a camera button on every figure downloads a 300 dpi PNG
  (`download_dpi`, chunk option `download = FALSE`).
- **ggplot2**: theme, 8-colour palette checked for colour blindness, discrete and
  continuous (sequential, diverging) scales, applied automatically in the report.
  Functions: `theme_greenOlive()`, `greenOlive_colors()`,
  `scale_colour_greenOlive()`, `scale_fill_greenOlive_c("seq" | "div")`, ...

All options: `?GRC_greenOlive`.

## Your logos

The package ships with two placeholder logos. To use your own (they stay on
your computer, not in this repository):

1. Make a folder with your logos named `logo_*` (colour versions, shown on a
   light badge) and, optionally, `logo_white_*` (used with `logo_chip: false`).
   Files are shown in alphabetical order: `logo_1_university.png`,
   `logo_2_lab.png`, ...
2. Point the theme to it, once, in your `.Rprofile`
   (`usethis::edit_r_profile()` opens it):

   ```r
   options(grcthemes.logos = "C:/Users/me/Documents/my-logos")
   ```

   or per report in the YAML: `logos: "path/to/folder"` (or a list of files).
   `logos: []` removes them.

## Repository layout

```
grcthemes/
├── R/
│   ├── themes.R            # theme registry: fonts, plot colours, palettes  <- edit for a new theme
│   ├── format.R            # shared output-format engine
│   ├── ggplot.R            # shared ggplot helpers
│   ├── gallery.R           # grc_gallery() and the gallery chunk option
│   ├── download.R          # 300 dpi download button (knitr hooks)
│   ├── GRC_greenOlive.R    # the GRC_greenOlive format + its ggplot functions
│   └── zzz.R               # registers the plot fonts when the package loads
└── inst/
    ├── themes/
    │   ├── shared/         # used by every theme
    │   │   ├── template.html   # page skeleton (pandoc template)
    │   │   ├── grc.css         # layout and components (uses only --grc-* variables)
    │   │   ├── grc.js          # menus, folding, galleries, download, footnotes
    │   │   ├── callouts.lua    # ::: note / self / attention
    │   │   └── logos/          # placeholder logos: logo_* (badge) and logo_white_*
    │   └── GRC_greenOlive/
    │       ├── theme.css       # colours and fonts (CSS variables only)
    │       └── fonts/          # .ttf files for plots + OFL licences
    └── rmarkdown/templates/
        ├── GRC_greenOlive/         # guide template
        └── GRC_greenOlive_blank/   # blank template
```

## Adding a new theme

Example: `GRC_blueSea`.

1. **Colours and fonts of the page**: copy `inst/themes/GRC_greenOlive/` to
   `inst/themes/GRC_blueSea/` and change the values in `theme.css`.
   Optional: `img/header.png` / `img/footer.png` (background images) and
   `logos/` (logos only for this theme; otherwise `shared/logos` is used).
2. **Plot fonts**: put the `.ttf` files in `inst/themes/GRC_blueSea/fonts/`
   (download from Google Fonts, keep the OFL licence file).
3. **Registry**: in `R/themes.R`, copy the `GRC_greenOlive = list(...)` entry,
   rename it `GRC_blueSea` and set `fonts_url`, `fonts`, `plot`, `palette`,
   `seq` and `div`.
4. **Functions**: copy `R/GRC_greenOlive.R` to `R/GRC_blueSea.R` and replace
   `GRC_greenOlive` / `greenOlive` with `GRC_blueSea` / `blueSea`.
5. **Package files**: add `'GRC_blueSea.R'` to `Collate:` in `DESCRIPTION`
   (before `'zzz.R'`), then run `roxygen2::roxygenise()` to update
   `NAMESPACE` and the help pages in `man/` (never edit those by hand).
6. **Templates** (optional): copy `inst/rmarkdown/templates/GRC_greenOlive*`
   and change the `output:` line.
7. Reinstall and render the guide with the new theme.

## Licences

Code and placeholder logos: MIT (see `LICENSE.md`). Fonts: SIL Open Font
License 1.1 (files in each `fonts/` folder).
