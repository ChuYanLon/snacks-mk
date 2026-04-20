local M = {}

local ROOT_NAME = "/ (root)"

function M.get_dirs_cmd(opts, filter)
  local use_fd = vim.fn.executable("fd") == 1 or vim.fn.executable("fdfind") == 1
  local cmd = use_fd and (vim.fn.executable("fd") == 1 and "fd" or "fdfind") or "find"

  local args = {}

  if cmd == "fd" or cmd == "fdfind" then
    args = { ".", "--type", "d", "--hidden", "--exclude", ".git", "--color", "never" }
  else
    args = { ".", "-type", "d", "-not", "-path", "*/.git/*" }
  end

  local excludes = opts.exclude or { "node_modules", "target", "build", "dist", ".venv", "__pycache__" }
  for _, e in ipairs(excludes) do
    if cmd == "fd" or cmd == "fdfind" then
      table.insert(args, "--exclude")
      table.insert(args, e)
    else
      table.insert(args, "-not")
      table.insert(args, "-path")
      table.insert(args, "*/" .. e .. "/*")
    end
  end

  if filter and filter.search and filter.search ~= "" and filter.search ~= " " then
    if cmd == "fd" or cmd == "fdfind" then
      table.insert(args, filter.search)
    end
  end
  local base_cmd = cmd

  local escaped_args = {}

  for _, arg in ipairs(args) do
    table.insert(escaped_args, vim.fn.shellescape(arg))
  end

  local cmd_str = base_cmd .. " " .. table.concat(escaped_args, " ")

  return "sh", { "-c", "echo '" .. ROOT_NAME .. "' && " .. cmd_str }
end

function M.normalize_path(path)
  return vim.fs.normalize(path)
end

function M.get_cwd()
  return vim.fs.normalize(vim.uv.cwd() or ".")
end

function M.get_relative_path(path)
  return vim.fn.fnamemodify(path, ":~:.")
end

function M.split_input(input_str)
  if not input_str or input_str == "" then
    return {}
  end
  return vim.split(input_str, ",", { trimempty = true })
end

function M.trim(str)
  return vim.trim(str)
end

function M.is_directory_path(path)
  return path:sub(-1) == "/" or path:sub(-1) == "\\"
end

return M