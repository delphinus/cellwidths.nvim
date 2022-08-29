local Template = require "cellwidths.template"

---@class cellwidths.user_template.UserTemplate: cellwidths.template.Template
local UserTemplate = {}

---@param nvim cellwidths.nvim.Nvim
---@name string
---@return cellwidths.user_template.UserTemplate
UserTemplate.new = function(nvim, name)
  local self = setmetatable({
    nvim = nvim,
    name = "user/" .. name,
  }, { __index = Template })
  return self ---[[@as cellwidths.user_template.UserTemplate]]
end

return UserTemplate
