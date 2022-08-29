local Nvim = require "cellwidths.nvim"
local Table = require "cellwidths.table"
local Template = require "cellwidths.template"

local nvim = Nvim.new()
local tbl = Table.new(nvim, {})

local tmpl = Template.new(nvim, "empty")
tmpl:save(tbl:get())
