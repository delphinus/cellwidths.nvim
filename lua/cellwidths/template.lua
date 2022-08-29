local parent_dir = (function()
  local source = debug.getinfo(2, "S").source
  local dir = source:gsub("@(.*)%/[^%/]+$", "%1")
  return dir
end)()

---@class cellwidths.template.Template
---@field nvim cellwidths.nvim.Nvim
---@field dir string
---@field name string
---@field _path string
local Template = {
  dir = parent_dir,
}

---@param nvim cellwidths.nvim.Nvim
---@param name string
---@return cellwidths.template.Template
Template.new = function(nvim, name)
  local self = setmetatable({
    nvim = nvim,
    name = name,
  }, { __index = Template })
  return self
end

---@return string
function Template:path()
  self._path = self._path or self.dir .. "/templates/" .. self.name .. ".lua"
  return self._path
end

---@return boolean
function Template:exists()
  return not not self.nvim.uv.fs_stat(self:path())
end

---@return table|nil
function Template:load()
  if not self:exists() then
    self.nvim.log:debug("template: %s not found", self.name)
    return
  end
  local ok, code = pcall(require, "cellwidths.templates." .. self.name)
  if not ok then
    self.nvim.log:debug("requiring template: %s failed", self.name)
    return
  end
  local f, err = loadstring(code, self.name)
  if not f then
    self.nvim.log:debug("loadstring template: %s failed: %s", self.name, err)
    return
  end
  local tbl = f()
  if type(tbl) ~= "table" then
    self.nvim.log:debug("loaded result is not a table: %s", self.name)
    return
  end
  return tbl
end

---@param tbl table
---@return boolean
function Template:save(tbl)
  local fd = self.nvim.uv.fs_open(self:path(), "w", tonumber("644", 8))
  if not fd then
    self.nvim.log:debug("cannot open file: %s", self:path())
    return false
  end
  local f, err = load("return " .. vim.inspect(tbl))
  if not f then
    self.nvim.log:debug("failed to create func: %s", err)
    return false
  end
  local code = string.dump(f, true)
  local result = self.nvim.uv.fs_write(fd, "return " .. vim.inspect(code))
  if type(result) ~= "number" then
    self.nvim.log:debug("cannot write code: %s", tostring(result))
    return false
  end
  self.nvim.uv.fs_close(fd)
  return true
end

---@return nil
function Template:remove()
  if self:exists() then
    local result = self.nvim.uv.fs_unlink(self:path())
    if result then
      self.nvim.log:info("successfully removed the template: %s", self.name)
    else
      self.nvim.log:error("cannot remove the template: %s", self.name)
    end
  else
    self.nvim.log:info("the template: %s does not exist", self.name)
  end
end

return Template
