---@class cellwidths.main.Options
---@field name string
---@field fallback fun(self: cellwidths): cellwidths
---@field log_level string
---@field initialized boolean

local Args = require "cellwidths.args"
local Table = require "cellwidths.table"
local Template = require "cellwidths.template"
local UserTemplate = require "cellwidths.user_template"

-- The main class
---@class cellwidths.main.CellWidths
---@field nvim cellwidths.nvim.Nvim
---@field default_options cellwidths.main.Options
---@field opts cellwidths.main.Options
---@field table cellwidths.table.Table
local CellWidths = {}

-- Constructor
---@param nvim cellwidths.nvim.Nvim
---@return cellwidths.main.CellWidths
CellWidths.new = function(nvim)
  return setmetatable({
    default_options = { name = "default", log_level = "INFO" },
    nvim = nvim,
    opts = {},
    table = Table.new(nvim),
    initialized = false,
  }, { __index = CellWidths })
end

-- The bootstrap function. Users should call this at the first.
---@param opts cellwidths.main.Options?
---@return cellwidths.main.CellWidths
function CellWidths:setup(opts)
  local s = os.clock()

  local is_user_template = self:is_user_template_name((opts or {}).name)

  ---@diagnostic disable-next-line: assign-type-mismatch
  self.opts = vim.tbl_extend("force", self.default_options, opts or {})
  vim.validate {
    name = { self.opts.name, "string" },
    fallback = {
      self.opts.fallback,
      ---@return boolean
      function(v)
        if is_user_template then
          return type(v) == "function"
        end
        return true
      end,
      'function necessary when name =~ "^user%/"',
    },
    log_level = {
      self.opts.log_level,
      ---@return boolean
      function(v)
        return not not vim.log.levels[v]
      end,
      "log level name. ex. ERROR, WARN, ……",
    },
  }

  self.nvim.log.level = vim.log.levels[self.opts.log_level]
  local tmpl
  if is_user_template then
    ---@return cellwidths.table.CellWidthTable
    local function fallback()
      self:load "empty"
      local cw = require "cellwidths"
      self.opts.fallback(cw)
      return self.table:get()
    end

    tmpl = UserTemplate.new(self.nvim, self.opts.name, fallback)
  else
    tmpl = Template.new(self.nvim, self.opts.name)
  end

  self:load_template(tmpl)
  self:setup_commands()
  self.initialized = true

  self.nvim.log:debug("setup() has taken %s milliseconds", (os.clock() - s) * 1000)
  return self
end

---@param name any
---@return boolean
-- luacheck: ignore self
function CellWidths:is_user_template_name(name)
  return type(name) == "string" and name:match "^user%/" and true or false
end

---@param name string
---@return cellwidths.main.CellWidths
function CellWidths:load(name)
  self.nvim.log:trace("name: %s", name)
  local tmpl = Template.new(self.nvim, name)
  self:load_template(tmpl)
  return self
end

---@param tmpl cellwidths.template.Template
---@return nil
function CellWidths:load_template(tmpl)
  local result = tmpl:load()
  if not result then
    self.nvim.log:error("template: %s loading failed: %s", tmpl.name)
    return
  end
  self.table:set(result.cw_table)
  if result.clean_up then
    self.table:clean_up()
  end
  self.nvim.log:trace(self.table:get())
  self.nvim.fn.setcellwidths(self.table:get())
  if result.save then
    local err = tmpl:save(self.table:get())
    if err then
      self.nvim.log:error("failed to save: %s", err)
      return
    end
  end
  self.nvim.log:debug("successfully loaded the table from %s", tmpl.name)
end

---@param entry cellwidths.table.CellWidthTable|cellwidths.table.CellWidthEntry|integer
---@param width cellwidths.table.CellWidth?
---@return cellwidths.main.CellWidths
function CellWidths:add(entry, width)
  self.nvim.log:trace("entry: %s, width: %s", entry, width)
  self.table:add(entry, width)
  return self
end

---@param entry integer[]|integer
---@return cellwidths.main.CellWidths
function CellWidths:delete(entry)
  self.nvim.log:trace("entry: %s", entry)
  self.table:delete(entry)
  return self
end

---@param name string
---@return nil
function CellWidths:remove(name)
  self.nvim.log:trace("name: %s", name)
  if self:is_user_template_name(name) then
    local tmpl = UserTemplate.new(self.nvim, name, function() end)
    tmpl:remove()
  else
    self.nvim.log:error("cannot remove non-user templates: %s", name)
  end
end

---@return nil
function CellWidths:apply()
  self.nvim.fn.setcellwidths(self.table:get())
end

---@return nil
function CellWidths:setup_commands()
  ---@param f fun(args: cellwidths.args.Args): nil
  ---@return fun(info: table): nil
  local function wrap(f)
    ---@param info table
    return function(info)
      if not self.initialized then
        self.nvim.log:error "not initialized. call setup() at first."
      end
      f(Args.new(self.nvim, info.args))
    end
  end

  self.nvim.api.nvim_create_user_command(
    "CellWidthsAdd",
    wrap(function(args)
      local entry, width = args:as_numbers_or_table()
      if not entry then
        self.nvim.log:error "invalid args"
        return nil
      end
      self:add(entry, width)
      self:apply()
    end),
    { nargs = "+" }
  )

  self.nvim.api.nvim_create_user_command(
    "CellWidthsDelete",
    wrap(function(args)
      local entry = args:as_numbers_or_table()
      if not entry then
        self.nvim.log:error "invalid args"
        return nil
      end
      self:delete(entry)
      self:apply()
    end),
    { nargs = "+" }
  )

  self.nvim.api.nvim_create_user_command(
    "CellWidthsLoad",
    wrap(function(args)
      local name = args:as_string()
      if not name then
        self.nvim.log:error "invalid args"
        return nil
      end
      self:load(name)
    end),
    { nargs = 1 }
  )

  self.nvim.api.nvim_create_user_command(
    "CellWidthsRemove",
    wrap(function(args)
      local name = args:as_string()
      if not name or name == "" then
        self:remove(self.opts.name)
      elseif name:match "^user%/" then
        self:remove(name)
      else
        self:remove("user/" .. name)
      end
    end),
    { nargs = "?" }
  )
end

return CellWidths
