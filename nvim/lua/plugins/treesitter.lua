return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ci_smoke = vim.env.DOTFILES_CI_SMOKE_NVIM == "1"
			local parser_install_dir = vim.fn.stdpath("data") .. "/site"
			if not ci_smoke then
				vim.opt.runtimepath:prepend(parser_install_dir)
			end

			require("nvim-treesitter.configs").setup({
				parser_install_dir = ci_smoke and nil or parser_install_dir,
				-- List of language parsers to install
				ensure_installed = ci_smoke and {} or {
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
				},
				auto_install = not ci_smoke,
				highlight = {
					enable = true,
					disable = { "markdown", "markdown_inline" },
				},
				indent = {
					enable = true,
					disable = { "markdown", "markdown_inline" },
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin
				max_lines = 0, -- 0 means no limit
				trim_scope = "inner", -- Or "outer"
				-- Avoid the 'range' nil value error in Neovim 0.12 nightly for markdown
				on_attach = function(buf)
					local ft = vim.bo[buf].filetype
					return ft ~= "markdown" and ft ~= "markdown_inline"
				end,
			})
		end,
	},
}
