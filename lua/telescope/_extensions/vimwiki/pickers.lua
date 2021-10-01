local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local live_grep = require("telescope.builtin").live_grep

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

M.vimwiki_grep = function(opts)
  local index = '0'
  if opts then
    if opts['index'] then
      index = opts['index']
    elseif opts['i'] then
      index = opts['i']
    end
  end

  --TODO(ElPiloto): Extend this to only get files matching wikilocal extension.
  vim.api.nvim_exec(':call vimwiki#vars#set_bufferlocal("wiki_nr", ' .. index .. ')', false)
  local vimwiki_path = vim.api.nvim_eval('vimwiki#vars#get_wikilocal("path")')
  --TODO(ElPiloto): Switch to using path = vim.g.vimwiki_wikilocal_vars[index]['path']
  live_grep({search_dirs = {vimwiki_path}})
end

return M
