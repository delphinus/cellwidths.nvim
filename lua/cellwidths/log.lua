---@class cellwidths.log.Log
---@field name string
---@field notify fun(msg: string, level: number|nil, opts: table|nil): nil
---@field level integer
local Log = {}

---@param notify fun(msg: string, level: number|nil, opts: table|nil): nil
---@return cellwidths.log.Log
Log.new = function(notify)
  local self = {
    name = "cellwidths",
    notify = notify,
    level = vim.log.levels.INFO,
  }
  return setmetatable(self, { __index = Log })
end

---@param fmt string
---@param ... string
---@return string
function Log:message(fmt, ...)
  local args = { ... }
  local msg = "[" .. self.name .. "] " .. fmt
  for _, arg in ipairs(args) do
    msg = msg:gsub("%%s", arg, 1)
  end
  return msg
end

---@param msg string
---@param level integer
---@return nil
function Log:log(msg, level)
  if level >= self.level then
    self.notify(msg, level)
  end
end

---@param fmt string
---@param ... string
---@return nil
function Log:error(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.ERROR)
end

---@param fmt string
---@param ... string
---@return nil
function Log:info(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.INFO)
end

---@param fmt string
---@param ... string
---@return nil
function Log:debug(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.DEBUG)
end

return Log
