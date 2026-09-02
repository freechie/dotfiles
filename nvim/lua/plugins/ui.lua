return {
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		opts = function()
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				[[    _   __                _         ]],
				[[   / | / /__  ____ _   __(_)___ ___ ]],
				[[  /  |/ / _ \/ __ \ | / / / __ `__ \]],
				[[ / /|  /  __/ /_/ / |/ / / / / / / /]],
				[[/_/ |_/\___/\____/|___/_/_/ /_/ /_/ ]],
			}

			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find File", ":Telescope find_files <CR>"),
				dashboard.button("n", "  New File", ":enew <CR>"),
				dashboard.button("r", "  Recent", ":Telescope oldfiles <CR>"),
				dashboard.button("g", "  Grep", ":Telescope live_grep <CR>"),
				dashboard.button("l", "󰒲  Lazy", ":Lazy <CR>"),
				dashboard.button("u", "󰚰  Update", ":Lazy sync <CR>"),
				dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
				dashboard.button("q", "  Quit", ":qa <CR>"),
			}

			dashboard.section.footer.val = ""

			return dashboard.opts
		end,
	},
}
