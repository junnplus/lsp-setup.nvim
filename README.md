# nvim-lsp-setup

A simple wrapper for [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) and [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer) to easily setup LSP servers.

## Installation

- Neovim >= 0.6.0
- nvim-lspconfig
- nvim-lsp-installer

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'junnplus/nvim-lsp-setup',
    requires = {
        'neovim/nvim-lspconfig',
        'williamboman/nvim-lsp-installer',
    }
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'junnplus/nvim-lsp-setup'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
```


## Usage

```lua
require('nvim-lsp-setup').setup({
    default_mappings = true,
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
    mappings = {
    -- Example mappings for telescope pickers
    -- gd = 'lua require"telescope.builtin".lsp_definitions()',
    -- gi = 'lua require"telescope.builtin".lsp_implementations()',
    -- gr = 'lua require"telescope.builtin".lsp_references()',
    },
    -- Global on_attach
    -- on_attach = function(client, bufnr) {
    --     utils.format_on_save(client)
    -- },
    servers = {
        -- Install LSP servers automatically
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
        -- Setup sumneko_lua with lua-dev
        -- sumneko_lua = require('lua-dev').setup({
        --     lspconfig = {
        --         on_attach = function(client, _)
        --              -- Disable formatting
        --              require('nvim-lsp-setup.utils').disable_formatting(client)
        --         end,
        --     },
        -- }),
    },
})
```

## Integrations

### [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)

If installed, will auto advertise capabilities to LSP servers.

## Contributing

Bug reports and feature requests are welcome! PRs are doubly welcome!
