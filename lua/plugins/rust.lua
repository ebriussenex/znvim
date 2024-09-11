return {
    { 'rust-lang/rust.vim' },
    {
        'mrcjkb/rustaceanvim',
        version = '^4',
        ft = { 'rust' },
        opts = {
            server = {
                default_settings = {
                    ['rust_analyzer'] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                            features = { 'excercises' },
                        },
                        -- Add clippy lints for Rust.
                        checkOnSave = {
                            allFeatures = true,
                            command = 'clippy',
                            extraArgs = { '--no-deps' },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ['async-trait'] = { 'async_trait' },
                                ['napi-derive'] = { 'napi' },
                                ['async-recursion'] = { 'async_recursion' },
                            },
                        },
                    },
                },
            },
        },
    },
}
