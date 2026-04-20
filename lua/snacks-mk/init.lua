local M = {}

local config = require("snacks-mk.config")
local picker = require("snacks-mk.picker")

function M.setup(opts)
	config.setup(opts)
	picker.register_source()

	vim.api.nvim_create_user_command("CreateInDir", function()
		picker.create_in_dir()
	end, { desc = "Choose a directory and create files/folders inside it" })
end

return M
