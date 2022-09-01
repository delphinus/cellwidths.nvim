---@class cellwidths
---@field cw cellwidths.main.CellWidths
---@field add fun(entry: cellwidths.table.CellWidthEntry, width: cellwidths.table.CellWidth?): cellwidths
---@field delete fun(entry: integer[]|integer): cellwidths
---@field load fun(name: string): cellwidths
---@field remove fun(name: string): cellwidths
---@field setup fun(opts: cellwidths.main.Options?): cellwidths

local CellWidths = require "cellwidths.main"
local Nvim = require "cellwidths.nvim"
local cw = CellWidths.new(Nvim.new())

return setmetatable({
  cw = cw,
  _exports = {
    add = true,
    delete = true,
    load = true,
    remove = true,
    setup = true,
  },
  _cache = {},
}, {
  __index = function(self, key)
    if not self._cache[key] then
      self._cache[key] = self._exports[key] and function(...)
        cw[key](cw, ...)
        return self
      end or function()
        cw.nvim.log:error("unknown method: %s", key)
      end
    end
    return self._cache[key]
  end,
}) --[[@as cellwidths ]]
