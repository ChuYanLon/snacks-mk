local M = {}

local function get_dirs_cmd(opts, filter)
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

  return cmd, args
end

local function directories_finder(opts, ctx)
  local cwd = vim.fs.normalize(opts.cwd or vim.uv.cwd() or ".")
  local cmd, args = get_dirs_cmd(opts, ctx.filter)
  if not cmd then
    return function() end
  end

  return require("snacks.picker.source.proc").proc(
    ctx:opts({
      cmd = cmd,
      args = args,
      notify = not opts.live,
      transform = function(item)
        item.cwd = cwd
        item.file = item.text
        item.dir = true
      end,
    }),
    ctx
  )
end

local function create_files_or_dirs(base_dir, input_str, opts)
  if not input_str or input_str == "" then
    return
  end

  local items = vim.split(input_str, ",", { trimempty = true })
  local created_files = {}

  for _, item in ipairs(items) do
    item = vim.trim(item)
    if item == "" then
      goto continue
    end

    local target = vim.fs.normalize(base_dir .. "/" .. item)

    if item:sub(-1) == "/" or item:sub(-1) == "\\" then
      -- Create directory
      local dir_path = target:sub(1, -2)
      vim.fn.mkdir(dir_path, "p")
      vim.notify("Created directory: " .. vim.fn.fnamemodify(dir_path, ":~:."))
    else
      -- Create file
      local parent = vim.fn.fnamemodify(target, ":h")
      vim.fn.mkdir(parent, "p")
      if vim.fn.filereadable(target) == 0 then
        local f = io.open(target, "w")
        if f then
          f:close()
        end
        vim.notify("Created file: " .. vim.fn.fnamemodify(target, ":~:."))
        table.insert(created_files, target)
      else
        vim.notify("File already exists: " .. vim.fn.fnamemodify(target, ":~:."))
      end
    end
    ::continue::
  end

  -- Open the first created file if requested
  if opts and opts.open_file and #created_files > 0 then
    vim.schedule(function()
      vim.cmd("edit " .. vim.fn.fnameescape(created_files[1]))
    end)
  end
end

local default_config = {
  exclude = { "node_modules", "target", "build", "dist", ".venv", "__pycache__" },
  live = true,
  open_file = true,
}

function M.setup(opts)
  local config = vim.tbl_deep_extend("force", default_config, opts or {})

  Snacks.picker.sources = Snacks.picker.sources or {}
  Snacks.picker.sources.directories = {
    finder = function(picker_opts, ctx)
      return directories_finder(vim.tbl_extend("force", picker_opts, { exclude = config.exclude, live = config.live }), ctx)
    end,
    format = "file",
    supports_live = true,
    hidden = true,
    show_empty = true,
  }

  vim.api.nvim_create_user_command("CreateInDir", function()
    Snacks.picker.directories({
      confirm = function(picker, item)
        picker:close()
        if not item or not item.file then
          return
        end
        local base_dir = item.file
        vim.ui.input({
          prompt = 'Create (file or dir/): use "," to separate',
          default = "",
          completion = "file",
        }, function(input)
          if input then
            create_files_or_dirs(base_dir, input, { open_file = config.open_file })
          end
          vim.schedule(function()
            vim.cmd("stopinsert")
          end)
        end)
        vim.schedule(function()
          vim.cmd("startinsert!")
        end)
      end,
    })
  end, { desc = "Choose a directory and create files/folders inside it" })
end

return M
