-- ~/.config/nvim/lua/config/lazy.lua
-- Plugin manager setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  -- Fuzzy finder with LSP integration
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "build/", "%.gradle/", "gradle/", "gradlew", "gradlew.bat", "%.apk", "%.aab",
            "node_modules/", "%.git/", "%.idea/", "%.vscode/",
            "DerivedData/", "%.xcworkspace/", "%.xcodeproj/", "Pods/",
            "%.DS_Store", "%.class", "%.jar", "%.war",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-e>"] = actions.select_vertical, 
            },
            n = {
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["q"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<A-v>"] = actions.select_vertical,
            },
          },
        },
        pickers = {
          lsp_references = { show_line = false },
          lsp_document_symbols = { symbol_width = 50 },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },
  -- Comment
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" }, 
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          opts.desc = opts.desc and ('GS: ' .. opts.desc)
          vim.keymap.set(mode, l, r, opts)
        end
        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr = true, desc = "Next Hunk"})
        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr = true, desc = "Previous Hunk"})
        -- Actions
        map({'n', 'v'}, '<leader>hs', gs.stage_hunk, {desc = "Stage Hunk"})
        map({'n', 'v'}, '<leader>hr', gs.reset_hunk, {desc = "Reset Hunk"})
        --map('n', '<leader>gS', gs.stage_buffer, {desc = "Stage Buffer"})
        map('n', '<leader>gR', gs.reset_buffer, {desc = "Reset Buffer"})
        map('n', '<leader>gu', gs.undo_stage_hunk, {desc = "Undo Stage Hunk"})
        map('n', '<leader>gp', gs.preview_hunk, {desc = "Preview Hunk"})
        map('n', '<leader>gb', function() gs.blame_line{full=true} end, {desc = "Blame Line (Full)"})
        map('n', '<leader>gB', gs.toggle_current_line_blame, {desc = "Toggle Current Line Blame"})
        --map('n', '<leader>gD', function() gs.diffthis('~') end, {desc = "Diff This ~ HEAD"}) -- Diff against last commit (HEAD)

        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = "Select Hunk (Inner Hunk text object)"})
      end
    }
  },
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
        }, 
      })
      local lspconfig = require('lspconfig')
      lspconfig.sourcekit.setup({ -- Swift LSP
        cmd = { "sourcekit-lsp" },
        filetypes = { "swift", "objc", "objcpp" },
        capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
        root_dir = function(fname)
          return require("lspconfig.util").find_git_ancestor(fname)
            or require("lspconfig.util").root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace")(fname)
            or vim.fn.getcwd()
        end,
      })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { silent = true })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { silent = true })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { silent = true })
      vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP Code Action" })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { silent = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        callback = function(args)
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { buffer = args.buf, desc = "Show Line Diagnostics" })
        end,
      })
    end,
  },
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4), ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" },
        }, { { name = "buffer" }, { name = "path" } }),
      })
    end,
  },
  -- Treesitter Configuration
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "javascript", "typescript", "tsx", "json", "html", "css",
          "markdown", "markdown_inline", "bash", "vim", "vimdoc",
        },
        sync_install = false, auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false, priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "moon", transparent = false })
      vim.cmd.colorscheme "tokyonight"
    end,
  },
  -- Terminal Manager
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      direction = 'float',
      open_mapping = [[<c-\>]],
    }
  },
  -- Keybinding Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },
  -- Formatting with conform.nvim
  {
    -- Formatting with conform.nvim
    {
      'stevearc/conform.nvim',
      event = { "BufWritePre" }, 
      cmd = { "ConformInfo" },
      opts = {
        formatters_by_ft = {
          javascript = { "prettierd", "prettier" }, 
          typescript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" }, 
          typescriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          markdown = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
          lua = { "stylua" }, 
        },

        format_on_save = {
          timeout_ms = 1000,      
          lsp_fallback = true,    
        },

      },
      format_on_save = { timeout_ms = 1000, lsp_fallback = true },
    },
  },
  -- Git Integration with fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },
  -- Color Previewer
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { '*' },
      user_default_options = {
        RGB = true, RRGGBB = true, RRGGBBAA = true,
        rgb_fn = true, hsl_fn = true,
        css = true, css_fn = true,
        mode = 'background',
      },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- For file icons
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  },
{
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- For file icons
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false, -- Show dotfiles (like .env, .gitignore)
        },
        git = {
          enable = true,
          ignore = false,
        },
      })
    end,
  },
})
