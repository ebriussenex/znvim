return {
    {
        'AlexvZyl/nordic.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('nordic').setup {
                bold_keywords = true,
                italic_comments = false,
                transparent_bg = true,
            }

            require('nordic').load()
        end,
    },
}
