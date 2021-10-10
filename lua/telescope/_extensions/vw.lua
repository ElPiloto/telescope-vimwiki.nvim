--Allow short-hand 'vw' for vimwiki
local vw_pickers = require'telescope._extensions.vimwiki.pickers'

return require'telescope'.register_extension{
  exports = {
    vw = vw_pickers.vimwiki_pages,
    live_grep = vw_pickers.vimwiki_grep,
    link = vw_pickers.vimwiki_link,
  }
}


