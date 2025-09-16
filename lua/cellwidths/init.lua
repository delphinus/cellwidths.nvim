---@class cellwidths
---@field cw cellwidths.main.CellWidths
---@field add fun(entry: cellwidths.table.CellWidthEntry, width: cellwidths.table.CellWidth?): cellwidths
---@field delete fun(entry: integer[]|integer): cellwidths
---@field load fun(name: string): cellwidths
---@field off fun(): cellwidths
---@field on fun(): cellwidths
---@field remove fun(name: string): cellwidths
---@field setup fun(opts: cellwidths.main.Options?): cellwidths

return setmetatable({
  _exports = {
    add = true,
    delete = true,
    load = true,
    off = true,
    on = true,
    remove = true,
    setup = true,
  },
  _cache = {},
}, {
  __index = function(self, key)
    if key == "cw" then
      if not self._cache.cw then
        local CellWidths = require "cellwidths.main"
        local Nvim = require "cellwidths.nvim"
        self._cache.cw = CellWidths.new(Nvim.new())
      end
      return self._cache.cw
    elseif not self._cache[key] then
      self._cache[key] = self._exports[key]
          and function(...)
            self.cw[key](self.cw, ...)
            return self
          end
        or function()
          self.cw.nvim.log:error("unknown method: %s", key)
        end
    end
    return self._cache[key]
  end,
}) --[[@as cellwidths ]]
