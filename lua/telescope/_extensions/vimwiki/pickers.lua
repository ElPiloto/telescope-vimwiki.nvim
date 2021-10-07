local pickers = require "telescope.pickers"
local make_entry = require "telescope.make_entry"
local sorters = require "telescope.sorters"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local live_grep = require("telescope.builtin").live_grep
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local flatten = vim.tbl_flatten

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

M.vimwiki_link = function(opts)
  local index = '0'
  if opts then
    if opts['index'] then
      index = opts['index']
    elseif opts['i'] then
      index = opts['i']
    end
  end

  vim.api.nvim_exec(':call vimwiki#vars#set_bufferlocal("wiki_nr", ' .. index .. ')', false)
  local vimwiki_path = vim.api.nvim_eval('vimwiki#vars#get_wikilocal("path")')
  local file_ext = vim.api.nvim_eval("vimwiki#vars#get_wikilocal('ext')")

  -- Escape the dot in the file_ext for pattern matching
  -- The extension should always start with a dot, right? this won't hurt anyway
  if string.sub(file_ext, 1, 1) == "." then
	file_ext = "%" .. file_ext
  end

  -- I couldn't find a way to override the default action of live_grep, so I copied its implementation from telescope source code and tweaked it a little to remove unwanted stuff
  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

  local filelist = {}

  local additional_args = {}
  if opts.additional_args ~= nil and type(opts.additional_args) == "function" then
    additional_args = opts.additional_args(opts)
  end

  local live_grepper = finders.new_job(function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local search_list = { vimwiki_path }
    return flatten { vimgrep_arguments, additional_args, "--", prompt, search_list }
  end, opts.entry_maker or make_entry.gen_from_vimgrep(
    opts
  ), opts.max_results, opts.cwd)

  pickers.new(opts, {
    prompt_title = "Vimwiki Link",
    finder = live_grepper,
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
		-- We only want the relative path. Using the absolute path works but it looks ugly
		local relative_path = string.gsub(selection[1], vimwiki_path, "")
		-- The selection is of the form file_path:line_number:column_number:selected_line_text
		-- We want to get the file_path only. The below pattern might catch false negatives if the file_path contains matching patterns but that will be very odd
		relative_path = string.gsub(relative_path, ":%d+:%d+:.+$", "")
		-- Finally, we remove the file extension. This is also not necessary, but it's the convention
		relative_path = string.gsub(relative_path, file_ext.."$", "")
		local link = "["..relative_path.."]".."("..relative_path..")"
        vim.api.nvim_put({link}, "", true, true)
      end)
      return true
    end,
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
