# nvim-lsp-setup

## Installation

- Neovim >= 0.6.0
- nvim-lspoconfig
- nvim-lsp-instanller

### packer

```lua
use {
    'junnplus/nvim-lsp-setup',
    requires = {
        'neovim/nvim-lspconfig',
        'williamboman/nvim-lsp-installer',
    }
}
```


## Setup

```lua
require('nvim-lsp-setup').setup({
    mappings = {
        -- Default mappings
        -- gD = 'lua vim.lsp.buf.declaration()',
        -- gd = 'lua vim.lsp.buf.definition()',
        -- gt = 'lua vim.lsp.buf.type_definition()',
        -- gi = 'lua vim.lsp.buf.implementation()',
        -- gr = 'lua vim.lsp.buf.references()',
        -- K = 'lua vim.lsp.buf.hover()',
        -- ['<C-k>'] = 'lua vim.lsp.buf.signature_help()',
        -- ['<space>rn'] = 'lua vim.lsp.buf.rename()',
        -- ['<space>ca'] = 'lua vim.lsp.buf.code_action()',
        -- ['<space>f'] = 'lua vim.lsp.buf.formatting()',
        -- ['<space>e'] = 'lua vim.lsp.diagnostic.show_line_diagnostics()',
        -- ['[d'] = 'lua vim.lsp.diagnostic.goto_prev()',
        -- [']d'] = 'lua vim.lsp.diagnostic.goto_next()',
    }
    servers = {
        -- Automatically install lsp server
        -- LSP server configuration please see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        pylsp = {},
        rust_analyzer = {
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        loadOutDirsFromCheck = true,
                    },
                    procMacro = {
                        enable = true,
                    },
                },
            },
        },
    },
})
```
