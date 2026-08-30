local Log = require "cellwidths.log"

-- `vim.loop` is deprecated since Neovim 0.10.
local uv = vim.uv or vim.loop

---@class cellwidths.nvim.Api
---@field nvim_create_user_command fun(name: string, command: (fun(info: table): nil), opts: any?): nil

---@class Option
---@field get fun(self: Option): { [string]: string }

---@class cellwidths.nvim.Opt
---@field listchars Option
---@field fillchars Option

--- Reads the option on every call.
---
--- `vim.opt.listchars` hands back the value as it is at that moment, so
--- holding on to it would hide any later change to the option from
--- |cellwidths.table.Table| and |cellwidths.user_template.UserTemplate|.
---@param name string
---@return Option
local function option(name)
  return {
    get = function()
      return vim.opt[name]:get()
    end,
  }
end

---@class cellwidths.nvim.Fn
---@field setcellwidths fun(tbl: table): nil
---@field str2list fun(str: string, utf8: boolean|nil): integer[]

---@class cellwidths.nvim.Uv
---@field fs_close fun(fd: number): nil
---@field fs_open fun(path: string, flags: string, mode: integer): integer|nil
---@field fs_stat fun(path: string): table|nil
---@field fs_unlink fun(path: string): string|nil
---@field fs_write fun(fd: number, data: string): integer|nil

---@class cellwidths.nvim.Nvim
---@field api cellwidths.nvim.Api
---@field fn cellwidths.nvim.Fn
---@field opt cellwidths.nvim.Opt
---@field uv cellwidths.nvim.Uv
---@field log cellwidths.log.Log
local Nvim = {}

---@return cellwidths.nvim.Nvim
Nvim.new = function()
  return {
    api = {
      nvim_create_user_command = vim.api.nvim_create_user_command,
    },
    fn = {
      setcellwidths = vim.fn.setcellwidths,
      str2list = vim.fn.str2list,
    },
    opt = {
      listchars = option "listchars",
      fillchars = option "fillchars",
    },
    uv = {
      fs_close = uv.fs_close,
      fs_open = uv.fs_open,
      fs_stat = uv.fs_stat,
      fs_unlink = uv.fs_unlink,
      fs_write = uv.fs_write,
    },
    log = Log.new(vim.notify),
  }
end

return Nvim
