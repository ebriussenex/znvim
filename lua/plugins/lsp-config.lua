-- try :h vim.lsp.buf

local mape = function(event)
    return function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
end

local setup_keymaps = function(event)
    local map = mape(event)
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    --  variables, functions, types, etc.
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
end

-- highlight same word on cursor
local hl_on_cursor = function(event, client)
    if client and client.server_capabilities.documentHighlightProvider then
        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
            end,
        })
    end
end

local enable_inlay_hints = function(event, client)
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        mape(event)('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, '[T]oggle Inlay [H]ints')
    end
end

local on_attach = function()
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
            setup_keymaps(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            hl_on_cursor(event, client)
            enable_inlay_hints(event, client)
        end,
    })
end

-- list of mason servers
local servers = {
    clangd = {},

    gopls = {},
    pyright = {},
    rust_analyzer = {},
}

return {
    {
        -- should be installed before mason-lspconfig
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end,
    },
    {
        'williamboman/mason-lspconfig.nvim',
        -- dependencies also means config of mason will run before this config func
        dependencies = { 'mason.nvim' },
        config = function()
            local handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup {}
                end,
                ['rust_analyzer'] = function()
                    require('rust-tools').setup {}
                end,
                ['lua_ls'] = function()
                    local lspconfig = require 'lspconfig'
                    lspconfig.lua_ls.setup {
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { 'vim' },
                                },
                            },
                        },
                    }
                end,
            }

            require('mason-lspconfig').setup {
                ensure_installed = vim.tbl_keys(servers or {}),
                handlers = handlers,
            }
        end,
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'j-hui/fidget.nvim', opts = {} },
        },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
            local lspconfig = require 'lspconfig'
            lspconfig.lua_ls.setup {
                capabilities = capabilities,
            }
            on_attach()
        end,
    },
}
