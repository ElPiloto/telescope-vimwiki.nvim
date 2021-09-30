local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local M = {}

M.vimwiki_pages = function(opts)
  --TODO: Optionally check if vimwiki index matches anything?
  local index = '0'
  if opts['index'] then
    index = opts['index']
  elseif opts['i'] then
    index = opts['i']
  end
  local vimwiki_cmd = 'vimwiki#base#find_files(' .. index .. ', 0)'
  pickers.new(opts, {
    prompt_title = "vimwiki pages",
    finder = finders.new_table {
      results = vim.api.nvim_eval(vimwiki_cmd)
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
