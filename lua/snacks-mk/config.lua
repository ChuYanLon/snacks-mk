local M = {}

local default_config = {
  exclude = { "node_modules", "target", "build", "dist", ".venv", "__pycache__" },
  live = true,
  open_file = true,
}

M.config = vim.deepcopy(default_config)

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

function M.get()
  return M.config
end

return M