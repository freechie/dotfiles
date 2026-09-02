return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = [[cd app && if [ -f yarn.lock ]; then if command -v yarn >/dev/null 2>&1; then yarn install --frozen-lockfile; else echo "markdown-preview.nvim: yarn is required for frozen lockfile install" >&2; exit 1; fi; elif [ -f package-lock.json ]; then npm ci; else echo "markdown-preview.nvim: no supported JS lockfile found" >&2; exit 1; fi]],
		keys = {
			{
				"<leader>mp",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "[M]arkdown [P]review Toggle",
			},
			{
				"<leader>ms",
				"<cmd>MarkdownPreviewStop<cr>",
				desc = "[M]arkdown [P]review [S]top",
			},
		},
	},
}
