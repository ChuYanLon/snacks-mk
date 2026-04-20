local M = {}

local config = require("snacks-mk.config")
local utils = require("snacks-mk.utils")

local ROOT_NAME = "/ (root)"

function M.directories_finder(opts, ctx)
	local cwd = utils.normalize_path(opts.cwd or utils.get_cwd())
	local cmd, args = utils.get_dirs_cmd(opts, ctx.filter)
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
				item.dir = true
				if item.text == ROOT_NAME then
					item.display_text = ROOT_NAME
					item.file = "."
				else
					item.display_text = item.text
					item.file = item.text
				end
			end,
		}),
		ctx
	)
end

function M.register_source()
	Snacks.picker.sources = Snacks.picker.sources or {}
	Snacks.picker.sources.directories = {
		finder = function(picker_opts, ctx)
			local cfg = config.get()
			return M.directories_finder(
				vim.tbl_extend("force", picker_opts, { exclude = cfg.exclude, live = cfg.live }),
				ctx
			)
		end,
		format = "file",
		supports_live = true,
		hidden = true,
		show_empty = true,
	}
end

function M.create_in_dir()
	local cfg = config.get()

	Snacks.picker.directories({
		confirm = function(picker, item)
			picker:close()
			if not item or not item.file then
				return
			end

			local base_dir
			if item.display_text == ROOT_NAME then
				base_dir = utils.get_cwd() .. "/"
			else
				base_dir = item.file .. "/"
			end

			vim.ui.input({
				prompt = 'Create (file or dir/): use "," to separate',
				default = "",
				completion = "file",
			}, function(input)
				if input then
					local creator = require("snacks-mk.creator")
					creator.create_files_or_dirs(base_dir, input, {
						open_file = cfg.open_file,
						open_all_files = cfg.open_all_files,
					})
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
end

return M
