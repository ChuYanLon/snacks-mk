local M = {}

local utils = require("snacks-mk.utils")

function M.create_files_or_dirs(base_dir, input_str, opts)
  if not input_str or input_str == "" then
    return
  end

  local items = utils.split_input(input_str)
  local created_files = {}

  for _, item in ipairs(items) do
    item = utils.trim(item)
    if item == "" then
      goto continue
    end

    local target = utils.normalize_path(base_dir .. "/" .. item)

    if utils.is_directory_path(item) then
      -- Create directory
      local dir_path = target:sub(1, -2)
      vim.fn.mkdir(dir_path, "p")
      vim.notify("Created directory: " .. utils.get_relative_path(dir_path))
    else
      -- Create file
      local parent = vim.fn.fnamemodify(target, ":h")
      vim.fn.mkdir(parent, "p")
      if vim.fn.filereadable(target) == 0 then
        local f = io.open(target, "w")
        if f then
          f:close()
        end
        vim.notify("Created file: " .. utils.get_relative_path(target))
        table.insert(created_files, target)
      else
        vim.notify("File already exists: " .. utils.get_relative_path(target))
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

return M