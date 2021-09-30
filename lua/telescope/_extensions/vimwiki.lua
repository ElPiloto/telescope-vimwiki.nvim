local vw_pickers = require'telescope._extensions.vimwiki.pickers'

return require'telescope'.register_extension{
  exports = {
    vimwiki = vw_pickers.vimwiki_pages
  }
}

