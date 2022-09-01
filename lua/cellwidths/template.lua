---@class cellwidths.template.LoadResult
---@field cw_table cellwidths.table.CellWidthTable
---@field clean_up boolean
---@field save boolean

local lib_dir = (function()
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
  lib_dir = lib_dir,
}

---@param nvim cellwidths.nvim.Nvim
---@param name string
---@return cellwidths.template.Template
Template.new = function(nvim, name)
  return setmetatable({ nvim = nvim, name = name }, { __index = Template })
end

---@return string
function Template:path()
  self._path = self._path or self.lib_dir .. "/templates/" .. self.name .. ".lua"
  return self._path
end

---@return boolean
function Template:exists()
  return not not self.nvim.uv.fs_stat(self:path())
end

---@return cellwidths.template.LoadResult?
function Template:load()
  if not self:exists() then
    self.nvim.log:trace("template %s not found", self.name)
    return nil
  end
  local cw_table = self:load_file(self.name)
  if not cw_table then
    self.nvim.log:trace("load template %s failed", self.name)
    return nil
  end
  return { cw_table = cw_table, clean_up = true, save = false }
end

---@return table?
function Template:load_file(name)
  local ok, code = pcall(require, "cellwidths.templates." .. name)
  if not ok then
    self.nvim.log:trace "requiring failed"
    return nil
  end
  local f = loadstring(code, self.name)
  if not f then
    self.nvim.log:trace "loadstring() failed"
    return nil
  end
  local tbl = f()
  if type(tbl) ~= "table" then
    self.nvim.log:trace "result from loadstring() is not a table"
    return nil
  end
  return tbl
end

---@param cw_table cellwidths.table.CellWidthTable
---@return string?
function Template:save(cw_table)
  local fd = self.nvim.uv.fs_open(self:path(), "w", tonumber("644", 8))
  if not fd then
    return "cannot open file: " .. self:path()
  end
  local f, err = load("return " .. vim.inspect(self:create_data(cw_table)))
  if not f then
    return "failed to create func: " .. err
  end
  local code = string.dump(f, true)
  local result = self.nvim.uv.fs_write(fd, "return " .. vim.inspect(code))
  if type(result) ~= "number" then
    return "cannot write code: " .. tostring(result)
  end
  self.nvim.uv.fs_close(fd)
  self.nvim.log:trace("successfully saved template: %s", self.name)
  return nil
end

---@param cw_table table
---@return table
-- luacheck: ignore self
function Template:create_data(cw_table)
  return { cw_table = cw_table }
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
