---@alias cellwidths.table.CellWidthEntry integer[]|integer
---@alias cellwidths.table.CellWidth 1|2
---@alias cellwidths.table.CellWidthTable cellwidths.table.CellWidthEntry[]
---@alias CharWidthMap table<string, cellwidths.table.CellWidth>

---@class cellwidths.table.Table
---@field nvim cellwidths.nvim.Nvim
---@field cw_table cellwidths.table.CellWidthTable
local Table = {}

---@param nvim cellwidths.nvim.Nvim
---@param cw_table cellwidths.table.CellWidthTable?
Table.new = function(nvim, cw_table)
  return setmetatable({ nvim = nvim, cw_table = cw_table or {} }, { __index = Table })
end

---@return cellwidths.table.CellWidthTable
function Table:get()
  return self.cw_table
end

---@param cw_table cellwidths.table.CellWidthTable
---@return nil
function Table:set(cw_table)
  self.cw_table = cw_table
end

---@return nil
function Table:clean_up()
  ---@param cw_table any
  ---@return boolean
  local function is_valid_table(cw_table)
    if type(cw_table) ~= "table" or not vim.tbl_islist(cw_table) then
      return false
    end
    for _, entry in ipairs(cw_table) do
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

  ---@param map CharWidthMap
  ---@return CharWidthMap
  local function remove_overlaps(map)
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

  if not is_valid_table(self.cw_table) then
    self.nvim.log:error "invalid table"
    return
  end
  local char_map = remove_overlaps(self:char_map())
  self:cw_table_from(char_map)
end

---@return CharWidthMap
function Table:char_map()
  ---@type CharWidthMap
  local result = {}
  for _, entry in ipairs(self.cw_table) do
    for i = entry[1], entry[2] do
      result[tostring(i)] = entry[3]
    end
  end
  return result
end

---@param char_map CharWidthMap
---@return nil
function Table:cw_table_from(char_map)
  ---@type integer[][]
  local entries = {}
  for k, v in pairs(char_map) do
    table.insert(entries, { tonumber(k, 10), v })
  end
  table.sort(entries, function(a, b)
    return a[1] < b[1]
  end)
  ---@type cellwidths.table.CellWidthTable
  local cw_table = {}
  for _, entry in ipairs(entries) do
    local code, width = entry[1], entry[2]
    if #cw_table == 0 then
      table.insert(cw_table, { code, code, width })
    else
      local last = cw_table[#cw_table]
      local end_code, w = last[2], last[3]
      if code == end_code + 1 and width == w then
        last[2] = code
      else
        table.insert(cw_table, { code, code, width })
      end
    end
  end
  self.cw_table = cw_table
end

---@param entry cellwidths.table.CellWidthTable|cellwidths.table.CellWidthEntry|integer
---@param width cellwidths.table.CellWidth?
---@return cellwidths.table.Table
function Table:add(entry, width)
  if type(entry) == "table" and #entry > 0 then
    local entries = type(entry[1]) == "table" and entry or { entry }
    for _, e in ipairs(entries) do
      table.insert(self.cw_table, e)
    end
  elseif type(entry) == "number" then
    table.insert(self.cw_table, { entry, entry, width })
  else
    self.nvim.log:error("invalid entry: %s", entry)
    return self
  end
  self:clean_up()
  return self
end

---@param entry integer[]|integer
---@return nil
function Table:delete(entry)
  local char_map = self:char_map()
  local entries = type(entry) == "table" and entry or { entry }
  for _, v in ipairs(entries) do
    local k = tostring(v)
    if char_map[k] then
      char_map[k] = nil
    end
  end
  self:cw_table_from(char_map)
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
