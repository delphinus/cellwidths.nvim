local uv = vim.loop
local log = require "cellwidths.log"

---@class cellwidths.file.Template
---@field dir string
---@field name string
---@field path string
local Template = {}

local parent_dir = (function()
  local source = debug.getinfo(2, "S").source
  local dir = source:gsub("@(.*)%/[^%/]+$", "%1")
  return dir
end)()

---@param name string
---@return cellwidths.file.Template
Template.new = function(name)
  local self = setmetatable({
    dir = parent_dir,
    name = name,
    path = parent_dir .. "/templates/" .. name .. ".lua",
  }, { __index = Template })
  return self
end

---@return boolean
function Template:exists()
  return not not uv.fs_stat(self.path)
end

---@return table|nil
function Template:load()
  if not self:exists() then
    log:debug("template: %s not found", self.name)
    return
  end
  local ok, code = pcall(require, "cellwidths.templates." .. self.name)
  if not ok then
    log:debug("requiring template: %s failed", self.name)
    return
  end
  local f, err = loadstring(code, self.name)
  if not f then
    log:debug("loadstring template: %s failed: %s", self.name, err)
    return
  end
  local tbl = f()
  if type(tbl) ~= "table" then
    log:debug("loaded result is not a table: %s", self.name)
    return
  end
  return tbl
end

---@param tbl table
---@return boolean
function Template:save(tbl)
  local fd = uv.fs_open(self.path, "w", tonumber("644", 8))
  if not fd then
    log:debug("cannot open file: %s", self.path)
    return false
  end
  local f, err = load("return " .. vim.inspect(tbl))
  if not f then
    log:debug("failed to create func: %s", err)
    return false
  end
  local code = string.dump(f, true)
  err = uv.fs_write(fd, "return " .. vim.inspect(code))
  if type(err) ~= "number" then
    log:debug("cannot write code: %s", err)
    return false
  end
  uv.fs_close(fd)
  return true
end

---@return nil
function Template:remove()
  if self:exists() then
    local result = uv.fs_unlink(self.path)
    if result then
      log:info("successfully removed the template: %s", self.name)
    else
      log:error("cannot remove the template: %s", self.name)
    end
  else
    log:info("the template: %s does not exist", self.name)
  end
end

return Template
