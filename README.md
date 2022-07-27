# nvim-lsp-setup

A simple wrapper for [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) to easily setup LSP servers.

## Installation

- Neovim >= 0.7
- nvim-lspconfig
- mason.nvim & mason-lspconfig.nvim

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'junnplus/nvim-lsp-setup',
    requires = {
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
    }
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'junnplus/nvim-lsp-setup'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
```


## Usage

```lua
require('nvim-lsp-setup').setup({
    servers = {
        pylsp = {}
    }
})
```

You can replace `pylsp` with the LSP server name you need, see [available LSPs](https://github.com/williamboman/nvim-lsp-installer#available-lsps).

### Setup structure

```lua
require('nvim-lsp-setup').setup({
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
    -- ['<space>e'] = 'lua vim.diagnostic.open_float()',
    -- ['[d'] = 'lua vim.diagnostic.goto_prev()',
    -- [']d'] = 'lua vim.diagnostic.goto_next()',
    default_mappings = true,
    -- Custom mappings, will overwrite the default mappings for the same key
    -- Example mappings for telescope pickers:
    -- gd = 'lua require"telescope.builtin".lsp_definitions()',
    -- gi = 'lua require"telescope.builtin".lsp_implementations()',
    -- gr = 'lua require"telescope.builtin".lsp_references()',
    mappings = {},
    -- Global on_attach
    on_attach = function(client, bufnr)
        require('nvim-lsp-setup.utils').format_on_save(client)
    end,
    -- Global capabilities
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    -- Configuration of LSP servers 
    servers = {
        -- Install LSP servers automatically
        -- LSP server configuration please see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        -- pylsp = {},
        -- rust_analyzer = {
        --     settings = {
        --         ['rust-analyzer'] = {
        --             cargo = {
        --                 loadOutDirsFromCheck = true,
        --             },
        --             procMacro = {
        --                 enable = true,
        --             },
        --         },
        --     },
        -- },
    },
})
```

## Integrations

### [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)

If installed, will auto advertise capabilities to LSP servers.

### [lua-dev](https://github.com/folke/lua-dev.nvim)

```lua
-- Setup sumneko_lua with lua-dev
require('nvim-lsp-setup').setup({
    servers = {
        sumneko_lua = require('lua-dev').setup({
            lspconfig = {
                settings = {
                    Lua = {
                        format = {
                            enable = true,
                        }
                    }
                }
            },
        }),
    }
})

```
### [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim)

Using `require('nvim-lsp-setup.rust-tools').setup({})` instead of `require('rust-tools').setup({})`.

```lua
require('nvim-lsp-setup').setup({
    servers = {
        rust_analyzer = require('nvim-lsp-setup.rust-tools').setup({
            server = {
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
        })
    }
})
```

### [clangd_extensions.nvim](https://github.com/p00f/clangd_extensions.nvim)

Using `require('nvim-lsp-setup.clangd_extensions').setup({})` instead of `require('clangd_extensions').setup({})`.

```lua
require('nvim-lsp-setup').setup({
    servers = {
        clangd = require('nvim-lsp-setup.clangd_extensions').setup({})
    }
})
```

## Contributing

Bug reports and feature requests are welcome! PRs are doubly welcome!
