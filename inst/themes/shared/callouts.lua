--[[ AeTa callouts
  No Rmd:
    ::: note                 -> nota geral (importancia 3)
    ::: self                 -> nota para mim mesma ("nao rode X por causa de Y")
    ::: attention            -> atencao (importancia 1), quadro translucido
  Titulo customizado:  ::: {.attention title="Do not mix sites"}
  As caixas "self" sao removidas do HTML quando grc_report(self_notes = FALSE).
]]

local show_self = true

local labels = { note = "Note", self = "Note to self", attention = "Attention" }

local svg = '<svg class="grc-callout-icon" viewBox="0 0 24 24" aria-hidden="true" fill="none" ' ..
            'stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
local icons = {
  -- "i" num circulo
  note = svg .. '<circle cx="12" cy="12" r="9.5"/><line x1="12" y1="11" x2="12" y2="16.5"/>' ..
         '<circle cx="12" cy="7.6" r="0.6" fill="currentColor"/></svg>',
  -- lapis
  self = svg .. '<path d="M4 20h4L19 9a2.1 2.1 0 0 0-3-3L5 17v3z"/><line x1="14" y1="7" x2="17" y2="10"/></svg>',
  -- triangulo de alerta
  attention = svg .. '<path d="M10.3 3.9 2.4 17.6A2 2 0 0 0 4.1 20.6h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>' ..
              '<line x1="12" y1="9.5" x2="12" y2="13.5"/><circle cx="12" cy="17" r="0.6" fill="currentColor"/></svg>',
}

local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function Meta(m)
  if m.grc_self_notes ~= nil then
    show_self = pandoc.utils.stringify(m.grc_self_notes) ~= "false"
  end
end

local function Div(el)
  for _, kind in ipairs({ "attention", "self", "note" }) do
    if el.classes:includes(kind) then
      if kind == "self" and not show_self then return {} end
      local title = el.attributes.title or labels[kind]
      el.attributes.title = nil
      el.classes:insert("grc-callout")
      el.classes:insert("grc-" .. kind)
      el.content:insert(1, pandoc.RawBlock("html",
        '<div class="grc-callout-title">' .. icons[kind] ..
        '<span>' .. escape(title) .. '</span></div>'))
      return el
    end
  end
end

return { { Meta = Meta }, { Div = Div } }
