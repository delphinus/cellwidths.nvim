local CellWidths = require "cellwidths.main"
local Nvim = require "cellwidths.nvim"
local cw = CellWidths.new(Nvim.new())

return setmetatable({
  cw = cw,
  _exports = {
    add = true,
    delete = true,
    remove = true,
    save = true,
    set = true,
    setup = true,
  },
  _cache = {},
}, {
  __index = function(self, key)
    if not self._cache[key] then
      self._cache[key] = self._exports[key] and function(...)
        cw[key](cw, ...)
      end or function()
        cw.nvim.log:error("unknown method: %s", key)
      end
    end
    return self._cache[key]
  end,
})
