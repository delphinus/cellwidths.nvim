---@alias Options { name: string, log_level: integer }

local Table = require "cellwidths.table"
local Template = require "cellwidths.template"

-- The main class
---@class cellwidths.main.CellWidths
---@field nvim cellwidths.nvim.Nvim
---@field default_options Options
---@field opts Options
---@field table cellwidths.table.Table
local CellWidths = {}

-- Constructor
---@param nvim cellwidths.nvim.Nvim
---@return cellwidths.main.CellWidths
CellWidths.new = function(nvim)
  local self = {
    nvim = nvim,
    default_options = { name = "default", log_level = "INFO" },
    opts = {},
    table = Table.new(nvim),
  }
  return setmetatable(self, { __index = CellWidths })
end

-- The bootstrap function. Users should call this at the first.
---@param opts Options?
---@return cellwidths.main.CellWidths
function CellWidths:setup(opts)
  ---@diagnostic disable-next-line: assign-type-mismatch
  self.opts = vim.tbl_extend("force", self.default_options, opts or {})
  vim.validate {
    name = { self.opts.name, "string" },
    log_level = {
      self.opts.log_level,
      function(v)
        return not not vim.log.levels[v]
      end,
      "log level",
    },
  }
  self.nvim.log.level = vim.log.levels[self.opts.log_level]
  ---@type boolean
  local is_custom = not not self.opts.name:match "^user%/"
  self:load(self.opts.name, is_custom)
  return self
end

---@param name string
---@param no_clean_up boolean|nil
---@return nil
function CellWidths:load(name, no_clean_up)
  local template = Template.new(self.nvim, name)
  if not template:exists() then
    self.nvim.log:error("template: %s not found", name)
    return
  end
  local tbl = template:load()
  if not tbl then
    self.nvim.log:error("template: %s loading failed", name)
    return
  end
  self.table:set(tbl, no_clean_up)
  self.nvim.fn.setcellwidths(self.table:get())
  self.nvim.log:debug("successfully loaded the table from %s", name)
end

---@param entry cellwidths.table.CellWidthEntry
---@param width cellwidths.table.CellWidth|nil
---@return cellwidths.table.Table
function CellWidths:add(entry, width)
  return self.table:add(entry, width)
end

---@param tbl cellwidths.table.CellWidthTable|nil
---@return nil
function CellWidths:set(entry, width)
  self:load "empty"
  if entry then
    self:add(entry, width)
  end
end

---@param name string
---@return nil
function CellWidths:save(name)
  local template = Template.new(self.nvim, "user/" .. name)
  if not template:save(self.table:get()) then
    self.nvim.log:error("cannot save the table: %s", name)
    return
  end
  self.nvim.log:info("successfully saved the table: %s", name)
end

---@param name string
---@return nil
function CellWidths:remove(name)
  local template = Template.new(self.nvim, "user/" .. name)
  template:remove()
end

return CellWidths
