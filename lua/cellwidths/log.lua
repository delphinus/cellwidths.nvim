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

---@param fmt any
---@param ... any
---@return string
function Log:message(fmt, ...)
  local function dump(v)
    return type(v) == "string" and v or vim.inspect(v)
  end

  local msg = "[" .. self.name .. "] " .. dump(fmt)
  -- Count with select() rather than ipairs(): a trailing nil argument would
  -- otherwise be skipped and leave a bare `%s` in the message.
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    -- `%` is special in a gsub replacement, so it has to be escaped or the
    -- call raises "invalid use of '%' in replacement string".
    msg = msg:gsub("%%s", (dump(arg):gsub("%%", "%%%%")), 1)
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

---@param fmt any
---@param ... any
---@return nil
function Log:error(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.ERROR)
end

---@param fmt any
---@param ... any
---@return nil
function Log:info(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.INFO)
end

---@param fmt any
---@param ... any
---@return nil
function Log:debug(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.DEBUG)
end

---@param fmt any
---@param ... any
---@return nil
function Log:trace(fmt, ...)
  self:log(self:message(fmt, ...), vim.log.levels.TRACE)
end

return Log
