---@class Opts
---@field listchars { [string]: string }
---@field fillchars { [string]: string }

---@class cellwidths.user_template.UserTemplateTable
---@field opts Opts
---@field cw_table cellwidths.table.CellWidthTable

local Template = require "cellwidths.template"

---@class cellwidths.user_template.UserTemplate: cellwidths.template.Template
---@field fallback fun(): cellwidths.table.CellWidthTable
local UserTemplate = setmetatable({}, { __index = Template })

---@param nvim cellwidths.nvim.Nvim
---@param name string
---@param fallback fun(): cellwidths.table.CellWidthTable
---@return cellwidths.user_template.UserTemplate
UserTemplate.new = function(nvim, name, fallback)
  return setmetatable({ nvim = nvim, name = name, fallback = fallback }, { __index = UserTemplate })
end

---@return cellwidths.template.LoadResult
function UserTemplate:load()
  ---@return cellwidths.user_template.UserTemplateTable?
  local function load_template()
    if not self:exists() then
      self.nvim.log:trace("%s does not exist", self.name)
      return nil
    end
    local tbl = self:load_file(self.name:gsub("%/", ".", 1))
    if not tbl then
      self.nvim.log:trace "load_file failed"
      return nil
    end
    if self:has_diff(tbl.opts) then
      self.nvim.log:trace "has diff"
      self.nvim.log:trace(tbl.opts)
      return nil
    end
    return tbl
  end

  local tbl = load_template()
  return tbl and { cw_table = tbl.cw_table, clean_up = false, save = false }
      or { cw_table = self.fallback(), clean_up = true, save = true }
end

---@param opts Opts?
---@return boolean
function UserTemplate:has_diff(opts)
  ---@param orig any
  ---@param new any
  ---@return boolean
  local function has_diff(orig, new)
    if type(orig) ~= "table" or type(new) ~= "table" then
      return false
    end
    for k, v in pairs(orig) do
      if v ~= new[k] then
        return true
      end
    end
    return false
  end

  local old_opts = opts or {}
  local new_opts = self:opts()
  return has_diff(old_opts.listchars, new_opts.listchars) or has_diff(old_opts.fillchars, new_opts.fillchars)
end

---@param cw_table cellwidths.table.CellWidthTable
---@return cellwidths.user_template.UserTemplateTable
function UserTemplate:create_data(cw_table)
  return {
    opts = self:opts(),
    cw_table = cw_table,
  }
end

---@return Opts
function UserTemplate:opts()
  return {
    listchars = self.nvim.opt.listchars:get(),
    fillchars = self.nvim.opt.fillchars:get(),
  }
end

return UserTemplate
