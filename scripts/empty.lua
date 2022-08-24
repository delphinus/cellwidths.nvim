local Table = require "cellwidths.table"
local Template = require "cellwidths.template"

local tbl = Table.new {}

local tmpl = Template.new "empty"
tmpl:save(tbl:get())
