return {
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				compile = true,
				undercurl = true,
				commentStyle = { italic = true },
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				transparent = true,
				terminalColors = true,
				theme = "wave",
				background = { dark = "wave", light = "lotus" },
			})
			vim.cmd("colorscheme kanagawa-wave")
		end,
	},

	{
		"cormacrelf/dark-notify",
		cond = function()
			return vim.fn.has("mac") == 1 and vim.fn.executable("dark-notify") == 1
		end,
		config = function()
			require("dark_notify").run({
				schemes = {
					dark = { colorscheme = "kanagawa-wave" },
					light = { colorscheme = "kanagawa-lotus" },
				},
			})
		end,
	},
}
