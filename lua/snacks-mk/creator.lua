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

    -- Remove trailing slash from base_dir if present to avoid double slashes
    local clean_base_dir = base_dir:gsub("/+$", "")
    local target = utils.normalize_path(clean_base_dir .. "/" .. item)

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

  -- Open created files if requested
  if opts and opts.open_file and #created_files > 0 then
    vim.schedule(function()
      if opts.open_all_files then
        -- Open all created files
        vim.cmd("edit " .. vim.fn.fnameescape(created_files[1]))
        
        -- Open remaining files in new buffers
        for i = 2, #created_files do
          vim.cmd("badd " .. vim.fn.fnameescape(created_files[i]))
        end
      else
        -- Only open the first file (backward compatibility)
        vim.cmd("edit " .. vim.fn.fnameescape(created_files[1]))
      end
    end)
  end
end

return M