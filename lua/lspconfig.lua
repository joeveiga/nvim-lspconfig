local configs = require 'lspconfig.configs'

local M = {
  util = require 'lspconfig.util',
}

function M.available_servers()
  vim.deprecate('lspconfig.available_servers', 'lspconfig.util.available_servers', '0.1.4', 'lspconfig')
  return M.util.available_servers()
end

---@class Alias
---@field to string The new name of the server
---@field version string The version that the alias will be removed in
---@param name string
---@return Alias
local function server_alias(name)
  local aliases = {
    ['fennel-ls'] = {
      to = 'fennel_ls',
      version = '0.2.0',
    },
    ['starlark-rust'] = {
      to = 'starlark_rust',
      version = '0.2.0',
    },
    sumneko_lua = {
      to = 'lua_ls',
      version = '0.2.0',
    },
  }

  return aliases[name]
end

local mt = {}
function mt:__index(k)
  if configs[k] == nil then
    local alias = server_alias(k)
    if alias then
      vim.deprecate(k, alias.to, alias.version, 'lspconfig')
      k = alias.to
    end

    local success, config = pcall(require, 'lspconfig.server_configurations.' .. k)
    if success then
      configs[k] = config
    else
      vim.notify(
        string.format(
          '[lspconfig] Cannot access configuration for %s. Ensure this server is listed in '
            .. '`server_configurations.md` or added as a custom server.',
          k
        ),
        vim.log.levels.WARN
      )
      -- Return a dummy function for compatibility with user configs
      return { setup = function() end }
    end
  end
  return configs[k]
end

return setmetatable(M, mt)
