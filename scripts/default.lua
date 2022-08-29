local Nvim = require "cellwidths.nvim"
local Table = require "cellwidths.table"
local Template = require "cellwidths.template"

local nvim = Nvim.new()
local tbl = Table.new(nvim, {
  { 0x2030, 0x203f, 2 },
  { 0x2103, 0x2103, 2 },
  { 0x2160, 0x2169, 2 },
  { 0x2170, 0x2179, 2 },
  { 0x2190, 0x2193, 2 },
  { 0x21d2, 0x21d2, 2 },
  { 0x21d4, 0x21d4, 2 },
  { 0x2266, 0x2267, 2 },
  { 0x2460, 0x24ff, 2 },
  { 0x25a0, 0x25a1, 2 },
  { 0x25b2, 0x25b3, 2 },
  { 0x25bc, 0x25bd, 2 },
  { 0x25c6, 0x25c7, 2 },
  { 0x25cb, 0x25cb, 2 },
  { 0x25cf, 0x25cf, 2 },
  { 0x2600, 0x267f, 2 },
  { 0x2690, 0x269c, 2 },
  { 0x26a0, 0x26ad, 2 },
  { 0x26b0, 0x26b1, 2 },
  { 0x26b9, 0x26b9, 2 },
  { 0x2701, 0x2709, 2 },
  { 0x270c, 0x2727, 2 },
  { 0x2729, 0x274d, 2 },
  { 0x274f, 0x2752, 2 },
  { 0x2756, 0x2756, 2 },
  { 0x2758, 0x275e, 2 },
  { 0x2761, 0x2794, 2 },
  { 0x2798, 0x279f, 2 },
  { 0x27f5, 0x27f7, 2 },
  { 0x2b05, 0x2b0d, 2 },
  { 0x303f, 0x303f, 2 },
  { 0xe62e, 0xe62e, 2 },
  { 0xf315, 0xf316, 2 },
  { 0xf31b, 0xf31c, 2 },
})

local tmpl = Template.new(nvim, "default")
tmpl:save(tbl:get())
