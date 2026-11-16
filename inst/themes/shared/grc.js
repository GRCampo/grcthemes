/* AeTa report navigation
 *   #  (level1)  -> item do menu principal
 *   ## (level2)  -> item do menu lateral da secao ativa
 * Mostra so a secao ## escolhida. A URL guarda a posicao (#id), entao links
 * internos, voltar/avancar do navegador e recarregar a pagina funcionam.
 */
(function () {
  "use strict";

  function isSection(el, level) {
    return el.nodeType === 1 && el.classList.contains("level" + level) &&
           (el.tagName === "SECTION" || el.classList.contains("section"));
  }
  function childSections(el, level) {
    return Array.prototype.filter.call(el.children, function (c) { return isSection(c, level); });
  }
  function headingText(sec) {
    var h = sec.querySelector("h1, h2");
    return h ? h.textContent.trim() : sec.id;
  }

  /* ---------- code folding ----------
   * body[data-code-folding] = "show" | "hide" | "none"
   * Cada bloco de codigo-fonte de um chunk (r, python, bash...) ganha um botao.
   * Blocos de exemplo (```markdown, ```yaml...) nao sao dobrados.
   * Chunks com class.source="fold-show" / "fold-hide" sobrepoem o padrao.
   */
  var FOLD_LANGS = /\b(r|python|bash|sh|sql|cpp|stan|julia|foldable|fold-show|fold-hide)\b/;
  var CODE_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" ' +
    'stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="8 6 2 12 8 18"/>' +
    '<polyline points="16 6 22 12 16 18"/></svg>';

  function setupCodeFolding(root) {
    var mode = document.body.getAttribute("data-code-folding");
    if (mode !== "show" && mode !== "hide") return [];

    var blocks = Array.prototype.filter.call(
      root.querySelectorAll("div.sourceCode, pre.sourceCode"),
      function (b) {
        if (b.tagName === "PRE" && b.parentNode.classList.contains("sourceCode")) return false;
        var pre = b.tagName === "PRE" ? b : b.querySelector("pre");
        return FOLD_LANGS.test(b.className + " " + (pre ? pre.className : ""));
      }
    );

    return blocks.map(function (block) {
      var pre = block.tagName === "PRE" ? block : block.querySelector("pre");
      var cls = block.className + " " + (pre ? pre.className : "");
      var open = /\bfold-show\b/.test(cls) ? true : /\bfold-hide\b/.test(cls) ? false : mode === "show";

      var wrap = document.createElement("div");
      wrap.className = "grc-fold";
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "grc-fold-btn";
      block.parentNode.insertBefore(wrap, block);
      wrap.appendChild(btn);
      wrap.appendChild(block);

      var fold = {
        isOpen: function () { return wrap.classList.contains("open"); },
        set: function (v) {
          wrap.classList.toggle("open", v);
          btn.innerHTML = CODE_ICON + (v ? "Hide code" : "Show code");
          btn.setAttribute("aria-expanded", v ? "true" : "false");
        },
        onChange: null
      };
      btn.addEventListener("click", function () {
        fold.set(!fold.isOpen());
        if (fold.onChange) fold.onChange();
      });
      fold.set(open);
      return fold;
    });
  }

  /* ---------- galeria ----------
   * Qualquer div.gallery (chunk com gallery = TRUE, bloco ::: gallery ou grc_gallery())
   * vira: imagem grande selecionada + faixa de miniaturas com setas.
   * Legenda: fig.cap / legenda da figura, ou o texto alternativo da imagem.
   */
  function setupGalleries(root) {
    Array.prototype.forEach.call(root.querySelectorAll("div.gallery"), function (box) {
      var imgs = Array.prototype.filter.call(box.querySelectorAll("img"), function (im) {
        return !im.closest(".sourceCode");
      });
      if (!imgs.length) return;

      var items = imgs.map(function (im) {
        var fig = im.closest(".figure, figure, .float");
        var cap = fig && fig.querySelector(".caption, figcaption, .figcaption");
        return {
          src: im.getAttribute("src"),
          caption: cap ? cap.textContent.trim() : (im.getAttribute("alt") || ""),
          dl: im.getAttribute("data-dl"),            // versao em alta resolucao (se houver)
          dlName: im.getAttribute("data-dl-name"),
          dlDpi: im.getAttribute("data-dl-dpi")
        };
      });

      // remove as figuras originais (o resto do conteudo, ex.: o codigo, fica)
      imgs.forEach(function (im) {
        var node = im.closest(".figure, figure, .float") || im;
        var parent = node.parentNode;
        parent.removeChild(node);
        if (parent !== box && parent.tagName === "P" && !parent.textContent.trim() && !parent.children.length) {
          parent.parentNode.removeChild(parent);
        }
      });

      var g = document.createElement("div");
      g.className = "grc-gallery";
      g.tabIndex = 0;
      g.innerHTML =
        '<figure class="grc-gallery-main"><img alt=""><figcaption>' +
        '<span class="grc-gallery-cap"></span><span class="grc-gallery-count"></span></figcaption></figure>' +
        '<div class="grc-gallery-strip">' +
        '<button type="button" class="grc-gallery-nav" data-dir="-1" aria-label="Previous">&#8249;</button>' +
        '<div class="grc-gallery-thumbs"></div>' +
        '<button type="button" class="grc-gallery-nav" data-dir="1" aria-label="Next">&#8250;</button></div>';
      box.appendChild(g);

      var main = g.querySelector(".grc-gallery-main img");
      var cap = g.querySelector(".grc-gallery-cap");
      var count = g.querySelector(".grc-gallery-count");
      var strip = g.querySelector(".grc-gallery-thumbs");
      var idx = 0;

      var thumbs = items.map(function (it, i) {
        var b = document.createElement("button");
        b.type = "button";
        b.className = "grc-gallery-thumb";
        b.title = it.caption;
        b.innerHTML = '<img alt="">';
        b.firstChild.src = it.src;
        b.addEventListener("click", function () { show(i); });
        strip.appendChild(b);
        return b;
      });

      function show(i) {
        idx = (i + items.length) % items.length;
        main.src = items[idx].src;
        main.alt = items[idx].caption;
        // o botao de download da imagem grande baixa a imagem selecionada
        ["dl", "dlName", "dlDpi"].forEach(function (k) {
          var attr = { dl: "data-dl", dlName: "data-dl-name", dlDpi: "data-dl-dpi" }[k];
          if (items[idx][k]) main.setAttribute(attr, items[idx][k]); else main.removeAttribute(attr);
        });
        cap.textContent = items[idx].caption;
        count.textContent = (idx + 1) + " / " + items.length;
        thumbs.forEach(function (t, k) { t.classList.toggle("active", k === idx); });
        var t = thumbs[idx];   // mantem a miniatura ativa visivel na faixa
        if (t.offsetLeft < strip.scrollLeft) strip.scrollLeft = t.offsetLeft - 8;
        else if (t.offsetLeft + t.offsetWidth > strip.scrollLeft + strip.clientWidth)
          strip.scrollLeft = t.offsetLeft + t.offsetWidth - strip.clientWidth + 8;
      }

      Array.prototype.forEach.call(g.querySelectorAll(".grc-gallery-nav"), function (b) {
        b.addEventListener("click", function () { show(idx + Number(b.getAttribute("data-dir"))); });
      });
      g.addEventListener("keydown", function (e) {
        if (e.key === "ArrowLeft")  { show(idx - 1); e.preventDefault(); }
        if (e.key === "ArrowRight") { show(idx + 1); e.preventDefault(); }
      });
      if (items.length === 1) g.classList.add("grc-gallery-single");
      show(0);
    });
  }

  /* ---------- botao de download (camera) em cada figura ----------
   * Figuras do knitr trazem data-dl (PNG em alta resolucao, ver R/download.R).
   * Outras figuras (markdown, grc_gallery) baixam a propria imagem.
   */
  var CAMERA_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" ' +
    'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
    '<path d="M4 8h3l2-3h6l2 3h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/>' +
    '<circle cx="12" cy="13" r="3.5"/></svg>';

  function downloadName(img, href) {
    if (img.getAttribute("data-dl-name")) return img.getAttribute("data-dl-name");
    var m = /^data:image\/([a-z+]+)/.exec(href);
    var ext = m ? m[1].replace("jpeg", "jpg").replace("svg+xml", "svg") : (href.split("?")[0].split(".").pop() || "png");
    var base = (img.getAttribute("alt") || "figure").trim().replace(/[^\w\-. ]+/g, "").replace(/\s+/g, "_") || "figure";
    return base + "." + ext;
  }

  function setupDownloads(root) {
    var imgs = Array.prototype.filter.call(root.querySelectorAll("img"), function (im) {
      if (im.closest(".grc-gallery-thumb, .grc-dl-wrap, .html-widget, .sourceCode")) return false;
      return im.hasAttribute("data-dl") || im.closest(".figure, figure, .float, .grc-gallery-main") ||
             (im.parentNode.tagName === "P" && im.parentNode.children.length === 1);
    });
    imgs.forEach(function (img) {
      var wrap = document.createElement("span");
      wrap.className = "grc-dl-wrap";
      img.parentNode.insertBefore(wrap, img);
      wrap.appendChild(img);

      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "grc-dl-btn";
      btn.innerHTML = CAMERA_ICON;
      var label = function () {
        var dpi = img.getAttribute("data-dl-dpi");
        return dpi ? "Download PNG (" + dpi + " dpi)" : "Download image";
      };
      btn.setAttribute("aria-label", label());
      btn.addEventListener("mouseenter", function () { btn.title = label(); });
      btn.addEventListener("click", function () {
        var href = img.getAttribute("data-dl") || img.currentSrc || img.src;
        var a = document.createElement("a");
        a.href = href;
        a.download = downloadName(img, href);
        document.body.appendChild(a);
        a.click();
        a.remove();
      });
      wrap.appendChild(btn);
    });
  }

  /* ---------- notas de rodape ----------
   * O pandoc junta todas as notas no fim do documento (fora das secoes), o que
   * as faria aparecer em todas as paginas. Move cada nota para o fim da pagina
   * (## ou #) onde ela e citada, mantendo a numeracao.
   */
  function relocateFootnotes(root) {
    var box = root.querySelector(".footnotes");
    if (!box) return;
    var pages = [], groups = [];
    Array.prototype.forEach.call(root.querySelectorAll("a.footnote-ref"), function (ref) {
      var id = decodeURIComponent((ref.getAttribute("href") || "").replace(/^#/, ""));
      var li = id && document.getElementById(id);
      var page = ref.closest(".level2") || ref.closest(".level1");
      if (!li || !page || !box.contains(li)) return;
      var num = parseInt(ref.textContent, 10);
      if (!isNaN(num)) li.value = num;
      var k = pages.indexOf(page);
      if (k < 0) { pages.push(page); groups.push([]); k = pages.length - 1; }
      groups[k].push(li);
    });
    pages.forEach(function (page, k) {
      var div = document.createElement("div");
      div.className = "footnotes grc-footnotes";
      var ol = document.createElement("ol");
      groups[k].forEach(function (li) { ol.appendChild(li); });
      div.appendChild(document.createElement("hr"));
      div.appendChild(ol);
      page.appendChild(div);
    });
    if (!box.querySelector("li")) box.parentNode.removeChild(box);
  }

  document.addEventListener("DOMContentLoaded", function () {
    var content  = document.getElementById("grc-content");
    var mainMenu = document.getElementById("grc-mainmenu");
    var sideMenu = document.getElementById("grc-sidemenu");
    var introLabel = content.getAttribute("data-intro-label") || "Overview";

    relocateFootnotes(content);
    var folds = setupCodeFolding(content);
    setupGalleries(content);
    setupDownloads(content);

    var chapters = childSections(content, 1);
    if (!chapters.length) {                 // documento sem "#": mostra tudo, sem menus
      mainMenu.style.display = "none";
      document.body.classList.add("grc-no-side");
      return;
    }

    // Conteudo de um "#" que vem antes do primeiro "##" vira uma pagina "intro"
    chapters.forEach(function (ch) {
      var h1 = ch.querySelector(":scope > h1");
      var loose = Array.prototype.filter.call(ch.childNodes, function (n) {
        return n !== h1 && !isSection(n, 2) && !(n.nodeType === 3 && !n.textContent.trim());
      });
      var hasSubs = childSections(ch, 2).length > 0;
      if (loose.length && hasSubs) {
        var intro = document.createElement("div");
        intro.className = "section level2 grc-intro";
        intro.id = ch.id + "-intro";
        intro.setAttribute("data-label", introLabel);
        var firstSub = childSections(ch, 2)[0];
        ch.insertBefore(intro, firstSub);
        loose.forEach(function (n) { intro.appendChild(n); });
      }
    });

    // Monta o menu principal
    chapters.forEach(function (ch) {
      var a = document.createElement("a");
      a.href = "#" + ch.id;
      a.textContent = headingText(ch);
      a.setAttribute("data-target", ch.id);
      mainMenu.appendChild(a);
    });

    // Botao global "mostrar/esconder todo o codigo", no canto direito do menu principal
    if (folds.length) {
      var all = document.createElement("button");
      all.type = "button";
      all.className = "grc-fold-all";
      var syncAll = function () {
        var anyOpen = folds.some(function (f) { return f.isOpen(); });
        all.innerHTML = CODE_ICON + (anyOpen ? "Hide all code" : "Show all code");
        all.setAttribute("data-next", anyOpen ? "hide" : "show");
      };
      all.addEventListener("click", function () {
        var open = all.getAttribute("data-next") === "show";
        folds.forEach(function (f) { f.set(open); });
        syncAll();
      });
      folds.forEach(function (f) { f.onChange = syncAll; });
      mainMenu.appendChild(all);
      syncAll();
    }

    var current = { ch: null, sub: null };

    function buildSide(ch) {
      sideMenu.innerHTML = "";
      var subs = childSections(ch, 2);
      document.body.classList.toggle("grc-no-side", subs.length === 0);
      subs.forEach(function (s) {
        var a = document.createElement("a");
        a.href = "#" + s.id;
        a.textContent = s.getAttribute("data-label") || headingText(s);
        a.setAttribute("data-target", s.id);
        sideMenu.appendChild(a);
      });
    }

    function activate(ch, sub, scrollTarget) {
      if (current.ch !== ch) {
        chapters.forEach(function (c) { c.classList.toggle("grc-hidden", c !== ch); });
        buildSide(ch);
      }
      var subs = childSections(ch, 2);
      if (!sub && subs.length) sub = subs[0];
      subs.forEach(function (s) { s.classList.toggle("grc-hidden", s !== sub); });

      Array.prototype.forEach.call(mainMenu.children, function (a) {
        a.classList.toggle("active", a.getAttribute("data-target") === ch.id);
      });
      Array.prototype.forEach.call(sideMenu.children, function (a) {
        a.classList.toggle("active", sub && a.getAttribute("data-target") === sub.id);
      });

      var changed = current.ch !== ch || current.sub !== sub;
      current = { ch: ch, sub: sub };

      if (scrollTarget) scrollTarget.scrollIntoView();
      else if (changed) content.scrollTop = 0;

      // htmlwidgets (plotly, leaflet...) precisam redimensionar ao aparecer
      if (changed) window.dispatchEvent(new Event("resize"));
    }

    function route() {
      var id = decodeURIComponent(location.hash.replace(/^#/, ""));
      var target = id ? document.getElementById(id) : null;
      if (!target || !content.contains(target)) { activate(chapters[0], null, null); return; }

      var ch = target.closest(".level1");
      var sub = target.closest(".level2");
      if (!ch) { activate(chapters[0], null, null); return; }
      if (sub && !ch.contains(sub)) sub = null;
      var deep = (target !== ch && target !== sub) ? target : null;  // ex.: um ### ou figura
      activate(ch, sub, deep);
    }

    window.addEventListener("hashchange", route);
    route();
    // o navegador rola ate a ancora sozinho ao carregar; desfaz isso para paginas inteiras
    window.addEventListener("load", function () {
      var id = decodeURIComponent(location.hash.replace(/^#/, ""));
      if (!id || id === (current.sub && current.sub.id) || id === current.ch.id) content.scrollTop = 0;
    });
  });
})();
