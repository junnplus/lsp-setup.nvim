# lsp-setup.nvim

A simple wrapper for [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) and [mason-lspconfig](https://github.com/mason-org/mason-lspconfig.nvim) (optional) to easily setup LSP servers.

## Requirements

- Neovim >= 0.11
- nvim-lspconfig >= 2.0.0
- mason.nvim & mason-lspconfig.nvim (optional)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```
{
  'junnplus/lsp-setup.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    'mason-org/mason.nvim', -- optional
    'mason-org/mason-lspconfig.nvim', -- optional
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'junnplus/lsp-setup.nvim',
  requires = {
    'neovim/nvim-lspconfig',
    'mason-org/mason.nvim', -- optional
    'mason-org/mason-lspconfig.nvim', -- optional
  }
}
```

## Usage

```lua
require('lsp-setup').setup({
  servers = {
    pylsp = {},
    clangd = {}
  }
})
```

You can replace `pylsp` with the LSP server name you need, see [available LSPs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md).

Also support installing custom versions of LSP servers (requires mason and mason-lspconfig), for example:

```lua
require('lsp-setup').setup({
  servers = {
    ['rust_analyzer@nightly'] = {}
  }
})
```

LSP servers returns a table will automatically setup server process using lspconfig. You can also pass a nil function to setup the server manually, see [Integrations/rust-tools.nvim](#rust-toolsnvim).

### Inlay hints

```lua
require('lsp-setup').setup({
  inlay_hints = {
    enabled = true,
  }
})
```

<details>
<summary>typescript-language-server</summary>
https://github.com/typescript-language-server/typescript-language-server#inlay-hints-textdocumentinlayhint

```lua
require('lsp-setup').setup({
  servers = {
    tsserver = {
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          }
        }
      }
    }
  }
})
```
</details>

<details>
<summary>vue-language-server</summary>

```lua
require('lsp-setup').setup({
  servers = {
    volar = {
      settings = {
        typescript = {
          inlayHints = {
            enumMemberValues = {
              enabled = true,
            },
            functionLikeReturnTypes = {
              enabled = true,
            },
            propertyDeclarationTypes = {
              enabled = true,
            },
            parameterTypes = {
              enabled = true,
              suppressWhenArgumentMatchesName = true,
            },
            variableTypes = {
              enabled = true,
            }
          }
        }
      }
    }
  }
})
```
</details>

<details>
<summary>gopls</summary>
https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md

```lua
require('lsp-setup').setup({
  servers = {
    gopls = {
      settings = {
        gopls = {
          hints = {
            rangeVariableTypes = true,
            parameterNames = true,
            constantValues = true,
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            functionTypeParameters = true,
          }
        }
      }
    }
  }
})
```
</details>

<details>
<summary>rust-analyzer</summary>
https://github.com/simrat39/rust-tools.nvim/wiki/Server-Configuration-Schema

```lua
require('lsp-setup').setup({
  servers = {
    rust_analyzer = {
      settings = {
        ['rust-analyzer'] = {
          inlayHints = {
            bindingModeHints = {
              enable = false,
            },
            chainingHints = {
              enable = true,
            },
            closingBraceHints = {
              enable = true,
              minLines = 25,
            },
            closureReturnTypeHints = {
              enable = 'never',
            },
            lifetimeElisionHints = {
              enable = 'never',
              useParameterNames = false,
            },
            maxLength = 25,
            parameterHints = {
              enable = true,
            },
            reborrowHints = {
              enable = 'never',
            },
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false,
            }
          }
        }
      }
    }
  }
})
```
</details>

<details>
<summary>
lua-language-server
</summary>
https://github.com/LuaLS/lua-language-server/wiki/Settings#hint

```lua
require('lsp-setup').setup({
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          hint = {
            enable = false,
            arrayIndex = "Auto",
            await = true,
            paramName = "All",
            paramType = true,
            semicolon = "SameLine",
            setType = false,
          },
        },
      },
    },
  }
})
```
</details>

<details>
<summary>zls</summary>
https://github.com/zigtools/zls

```lua
require('lsp-setup').setup({
  servers = {
    zls = {
      settings = {
        zls = {
          enable_inlay_hints = true,
          inlay_hints_show_builtin = true,
          inlay_hints_exclude_single_argument = true,
          inlay_hints_hide_redundant_param_names = false,
          inlay_hints_hide_redundant_param_names_last_token = false,
        }
      }
    },
  }
})
```
</details>

### Setup structure

```lua
require('lsp-setup').setup({
  -- Default mappings
  -- gD = { cmd = vim.lsp.buf.declaration, opts = { desc = 'Go To Declaration' } },
  -- gd = { cmd = vim.lsp.buf.definition, opts = { desc = 'Go To Definition' } },
  -- gi = { cmd = vim.lsp.buf.implementation, opts = { desc = 'Go To Implementation' } },
  -- gr = { cmd = vim.lsp.buf.references, opts = { desc = 'Go To References' } },
  -- K = { cmd = vim.lsp.buf.hover, opts = { desc = 'Hover' } },
  -- ['<C-k>'] = { cmd = vim.lsp.buf.signature_help, opts = { desc = 'Show Signature Help' } },
  -- ['<space>rn'] = { cmd = vim.lsp.buf.rename, opts = { desc = 'Rename' } },
  -- ['<space>ca'] = { cmd = vim.lsp.buf.code_action, opts = { desc = 'Code Action' } },
  -- ['<space>f'] = { cmd = vim.lsp.buf.formatting, opts = { desc = 'Format' } },
  -- ['<space>e'] = { cmd = vim.diagnostic.open_float, opts = { desc = 'Show Diagnostics' } },
  -- ['[d'] = { cmd = function() vim.diagnostic.jump({ count = -1, float = true }) end, opts = { desc = 'Prev Diagnostic' } },
  -- [']d'] = { cmd = function() vim.diagnostic.jump({ count = 1, float = true }) end, opts = { desc = 'Next Diagnostic' } },
  default_mappings = true,
  -- Custom mappings, will overwrite the default mappings for the same key
  -- Example mappings for telescope pickers:
  -- gd = 'lua require"telescope.builtin".lsp_definitions()',
  -- gi = 'lua require"telescope.builtin".lsp_implementations()',
  -- gr = 'lua require"telescope.builtin".lsp_references()',
  mappings = {},
  -- Global on_attach
  on_attach = function(client, bufnr)
    -- Support custom the on_attach function for global
    -- Formatting on save as default
    require('lsp-setup.utils').format_on_save(client)
  end,
  -- Global capabilities
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  -- Configuration of LSP servers 
  servers = {
    -- Install LSP servers automatically (requires mason and mason-lspconfig)
    -- LSP server configuration please see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    -- pylsp = {},
    -- rust_analyzer = {
    --   settings = {
    --     ['rust-analyzer'] = {
    --       cargo = {
    --         loadOutDirsFromCheck = true,
    --       },
    --       procMacro = {
    --         enable = true,
    --       },
    --     },
    --   },
    -- },
  },
  -- Configuration of LSP inlay hints
  inlay_hints = {
    enabled = false,
    highlight = 'Comment',
  }
})
```

## Integrations

### [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) or [coq_nvim](https://github.com/ms-jpq/coq_nvim) or [blink.cmp](https://github.com/Saghen/blink.cmp)

If installed, will auto advertise capabilities to LSP servers.

### [lazydev](https://github.com/folke/lazydev.nvim)

```lua
-- Setup lua_ls with lazydev
require('lazydev').setup()
require('lsp-setup').setup({
  servers = {
    lua_ls = {}
  }
})
```

### [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim)

```lua
require('lsp-setup').setup({
  servers = {
    rust_analyzer = function()
      require('rust-tools').setup({
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
      -- no need to return anything
    end,
  }
})
```

## Contributing

Bug reports and feature requests are welcome! PRs are doubly welcome!
