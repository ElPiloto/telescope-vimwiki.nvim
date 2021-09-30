local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local M = {}

M.vimwiki_pages = function(opts)
  local vimwiki_cmd = 'vimwiki#base#find_files(0, 0)'
  pickers.new(opts, {
    prompt_title = "vimwiki pages",
    finder = finders.new_table {
      results = vim.api.nvim_eval(vimwiki_cmd)
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
