local Log = require "cellwidths.log"

---@class Option
---@field get fun(self: Option): { [string]: string }

---@class cellwidths.nvim.Opt
---@field listchars Option
---@field fillchars Option

---@class cellwidths.nvim.Fn
---@field char2nr fun(str: string, utf8: boolean|nil): integer
---@field setcellwidths fun(tbl: table): nil

---@class cellwidths.nvim.Uv
---@field fs_close fun(fd: number): nil
---@field fs_open fun(path: string, flags: string, mode: integer): integer|nil
---@field fs_stat fun(path: string): table|nil
---@field fs_unlink fun(path: string): string|nil
---@field fs_write fun(fd: number, data: string): integer|nil

---@class cellwidths.nvim.Nvim
---@field fn cellwidths.nvim.Fn
---@field opt cellwidths.nvim.Opt
---@field uv cellwidths.nvim.Uv
---@field log cellwidths.log.Log
local Nvim = {}

---@return cellwidths.nvim.Nvim
Nvim.new = function()
  return {
    fn = {
      char2nr = vim.fn.char2nr,
      setcellwidths = vim.fn.setcellwidths,
    },
    opt = {
      listchars = vim.opt.listchars,
      fillchars = vim.opt.fillchars,
    },
    uv = {
      fs_close = vim.loop.fs_close,
      fs_open = vim.loop.fs_open,
      fs_stat = vim.loop.fs_stat,
      fs_unlink = vim.loop.fs_unlink,
      fs_write = vim.loop.fs_write,
    },
    log = Log.new(vim.notify),
  }
end

return Nvim
