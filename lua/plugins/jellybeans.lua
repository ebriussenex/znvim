return {
	"nanotech/jellybeans.vim",
	lazy = false,
	priority = 1000,
	config = function()
		-- TODO: remove it when learn to persist schemes
		vim.cmd([[colorscheme jellybeans]])
	end,
}
