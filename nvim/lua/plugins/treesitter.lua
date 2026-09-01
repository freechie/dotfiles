local languages = {
	"python",
	"javascript",
	"typescript",
	"tsx",
	"html",
	"css",
	"json",
	"yaml",
	"bash",
	"php",
	"java",
	"c",
	"cpp",
	"rust",
	"ruby",
	"go",
	"sql",
	"htmldjango",
	"regex",
	"markdown",
	"markdown_inline",
	"latex",
}

local disabled_filetypes = {
	markdown = true,
	markdown_inline = true,
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ci_smoke = vim.env.DOTFILES_CI_SMOKE_NVIM == "1"
			local treesitter = require("nvim-treesitter")

			treesitter.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			if not ci_smoke then
				treesitter.install(languages)
			end

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local filetype = vim.bo[ev.buf].filetype
					if disabled_filetypes[filetype] then
						return
					end

					local started = pcall(vim.treesitter.start, ev.buf)
					if started then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 0,
				trim_scope = "inner",
				on_attach = function(buf)
					local ft = vim.bo[buf].filetype
					return ft ~= "markdown" and ft ~= "markdown_inline"
				end,
			})
		end,
	},
}
