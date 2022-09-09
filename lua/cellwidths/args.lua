---@class cellwidths.args.Args
---@field nvim cellwidths.nvim.Nvim
---@field raw_args string
local Args = {}

---@param nvim cellwidths.nvim.Nvim
---@param raw_args string
---@return cellwidths.args.Args
Args.new = function(nvim, raw_args)
  return setmetatable({ nvim = nvim, raw_args = raw_args }, { __index = Args })
end

---@return string?
function Args:as_string()
  local f, err = loadstring('return "' .. self.raw_args .. '"')
  if not f then
    self.nvim.log:debug("err: %s", err)
    return nil
  end
  local name = f()
  if type(name) ~= "string" then
    self.nvim.log:debug("type: %s", type(name))
    return nil
  end
  return name
end

---@return cellwidths.table.CellWidthTable|cellwidths.table.CellWidthEntry|integer?, integer?
function Args:as_numbers_or_table()
  local f, err = loadstring("return " .. self.raw_args)
  if not f then
    self.nvim.log:debug("err: %s", err)
    return nil
  end
  return f()
end

return Args
