local Log = require "cellwidths.log"

---@class Option
---@field get fun(self: Option): string

---@alias cellwidths.nvim.Opt { listchars: Option, fillchars: Option }

---@alias Char2nr fun(str: string, utf8: boolean|nil): integer
---@alias Setcellwidths fun(tbl: table): nil
---@alias cellwidths.nvim.Fn { char2nr: Char2nr, setcellwidths: Setcellwidths }

---@alias FsClose fun(fd: number): nil
---@alias FsOpen fun(path: string, flags: string, mode: integer): integer|nil
---@alias FsStat fun(path: string): table|nil
---@alias FsUnlink fun(path: string): string|nil
---@alias FsWrite fun(fd: number, data: string): integer|nil
---@alias cellwidths.nvim.Uv { fs_close: FsClose, fs_open: FsOpen, fs_stat: FsStat, fs_unlink: FsUnlink, fs_write: FsWrite }

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
