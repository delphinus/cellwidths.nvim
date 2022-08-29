---@alias cellwidths.table.CellWidthEntry integer[]
---@alias cellwidths.table.CellWidth 1|2
---@alias cellwidths.table.CellWidthTable cellwidths.table.CellWidthEntry[]
---@alias CharWidthMap table<string, cellwidths.table.CellWidth>

---@class cellwidths.table.Table
---@field nvim cellwidths.nvim.Nvim
---@field cw_table cellwidths.table.CellWidthTable
---@field char_map CharWidthMap
local Table = {}

---@param nvim cellwidths.nvim.Nvim
---@param tbl cellwidths.table.CellWidthTable|nil
Table.new = function(nvim, tbl)
  local self = setmetatable({ nvim = nvim }, { __index = Table })
  self:set(tbl or {}, true)
  return self
end

---@return cellwidths.table.CellWidthTable
function Table:get()
  return self.cw_table
end

---@param tbl cellwidths.table.CellWidthTable
---@param no_clean_up boolean|nil
---@return nil
function Table:set(tbl, no_clean_up)
  self.cw_table = tbl
  if not no_clean_up then
    self:clean_up()
  end
end

---@return nil
function Table:clean_up()
  if not self:is_valid_table(self.cw_table) then
    self.nvim.log:error "invalid table"
    return
  end
  self.char_map = self:remove_overlaps(self:table_to_map(self.cw_table))
  self.cw_table = self:map_to_table(self.char_map)
end

---@param tbl any
---@return boolean
function Table:is_valid_table(tbl)
  if type(tbl) ~= "table" or not vim.tbl_islist(tbl) then
    return false
  end
  for _, entry in ipairs(tbl) do
    if #entry ~= 3 then
      return false
    end
    local not_number = vim.tbl_filter(function(v)
      return type(v) ~= "number"
    end, entry)
    if #not_number > 0 or entry[1] < 0x100 or entry[2] < 0x100 or (entry[3] ~= 1 and entry[3] ~= 2) then
      return false
    end
  end
  return true
end

---@param tbl cellwidths.table.CellWidthTable
---@return CharWidthMap
function Table:table_to_map(tbl)
  ---@type CharWidthMap
  local result = {}
  for _, entry in ipairs(tbl) do
    for i = entry[1], entry[2] do
      result[tostring(i)] = entry[3]
    end
  end
  return result
end

---@param map CharWidthMap
---@return CharWidthMap
function Table:remove_overlaps(map)
  for _, opt in ipairs { self.nvim.opt.listchars:get(), self.nvim.opt.fillchars:get() } do
    for _, v in pairs(opt) do
      local key = tostring(self.nvim.fn.char2nr(v, true))
      if map[key] == 2 then
        map[key] = 1
      end
    end
  end
  return map
end

---@param map CharWidthMap
---@return cellwidths.table.CellWidthTable
function Table:map_to_table(map)
  ---@type integer[][]
  local entries = {}
  for k, v in pairs(map) do
    table.insert(entries, { tonumber(k, 10), v })
  end
  table.sort(entries, function(a, b)
    return a[1] < b[1]
  end)
  ---@type cellwidths.table.CellWidthTable
  local tbl = {}
  for _, entry in ipairs(entries) do
    local code, width = entry[1], entry[2]
    if #tbl == 0 then
      table.insert(tbl, { code, code, width })
    else
      local last = tbl[#tbl]
      local end_code, w = last[2], last[3]
      if code == end_code + 1 and width == w then
        last[2] = code
      else
        table.insert(tbl, { code, code, width })
      end
    end
  end
  return tbl
end

---@param entry cellwidths.table.CellWidthEntry|integer
---@param width cellwidths.table.CellWidth|nil
---@return cellwidths.table.Table
function Table:add(entry, width)
  if type(entry) == "table" and #entry > 0 then
    table.insert(self.cw_table, entry)
  elseif type(entry) == "number" then
    table.insert(self.cw_table, { entry, entry, width })
  else
    self.nvim.log:error("invalid entry: %s", vim.inspect(entry))
    return self
  end
  self:clean_up()
  return self
end

---@return string
function Table:dump()
  ---@type string
  local inspected = vim.inspect(self.cw_table)
  local dumped = inspected:gsub("[a-f%d]+", function(v)
    return (v == "1" or v == "2") and v or ("0x%x"):format(v)
  end)
  return dumped
end

---@return string
function Table:vim_dump()
  local dumped =
    self:dump():gsub("{", "[", 1):gsub("}$", "]"):gsub("{ (0x[a-f%d]+), (0x[a-f%d]+), ([12]) },", "[ %1, %2, %3 ],")
  return dumped
end

return Table
