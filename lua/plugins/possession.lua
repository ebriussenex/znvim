return {
    {
        'jedrzejboczar/possession.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {
            autosave = {
                current = true,
                on_quit = true,
                cwd = true,
            },
            autoload = {
                cwd = true,
            },
            hooks = {
                -- returns table of user data
                -- here for now saving current colorscheme for every session
                before_save = function(_)
                    return {
                        colorscheme = vim.g.colors_name,
                    }
                end,
                after_load = function(_, user_data)
                    vim.cmd('colorscheme ' .. user_data.colorscheme)
                end,
            },
        },
    },
}
