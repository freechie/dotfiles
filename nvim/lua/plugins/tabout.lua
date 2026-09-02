return {
	{
		"abecodes/tabout.nvim",
		lazy = false, -- tabout must hook keypresses on startup
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("tabout").setup({
				tabkey = "<A-l>",
				backwards_tabkey = "<A-h>",
				act_as_tab = false,
				act_as_shift_tab = false,
				enable_backwards = true,
				completion = true,
				tabouts = {
					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "`", close = "`" },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
					{ open = "{", close = "}" },
					{ open = "<", close = ">" },
				},
				ignore_beginning = true,
				exclude = {},
			})
		end,
	},
}
