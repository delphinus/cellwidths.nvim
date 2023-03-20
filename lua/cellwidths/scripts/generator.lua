local source = debug.getinfo(1, "S").source:sub(2)
local path = source:match "^/" and source or vim.loop.cwd() .. "/" .. source
local plugin_dir = vim.fs.dirname(vim.fs.find(".git", { upward = true, path = path })[1])
vim.opt.runtimepath:append(plugin_dir)

local Nvim = require "cellwidths.nvim"
local Table = require "cellwidths.table"
local Template = require "cellwidths.template"

local nvim = Nvim.new()
local name = vim.v.argv[#vim.v.argv]
local ok, cw_table = pcall(require, "cellwidths.scripts." .. name)
if not ok then
  error(([[not found the template: %s
Usage: nvim -l %s [name]
]]):format(name, source))
end
local tbl = Table.new(nvim, cw_table)
local tmpl = Template.new(nvim, name)
tmpl:save(tbl:get())
