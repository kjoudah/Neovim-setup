-- ~/.config/nvim/lua/config/lazy.lualaz
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
      local actions = require("telescope.actions") -- Make sure you require actions
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
            },
            n = {
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["q"] = actions.close,
              ["<CR>"] = actions.select_default,
            },
          },
        },
        pickers = {
          lsp_references = { show_line = false },
          lsp_document_symbols = { symbol_width = 50 },
        },
        -- extensions = { -- Alternative way to configure fzf extension
        --   fzf = {}
        -- }
      })
      -- Load fzf extension after the main setup
      require("telescope").load_extension("fzf")
    end,
  },
  -- Comment
  {
    "numToStr/Comment.nvim",
    opts = {}, -- This will run the default setup
    -- Or if you want to call setup explicitly and pass options:
    -- config = function()
    --   require('Comment').setup({
    --     -- your custom config here
    --   })
    -- end,
  },
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" }, 
    opts = {
      signcolumn = true,  
      numhl = false,      
      linehl = false,     
      word_diff = false,  
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, 
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', 
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, 
      max_file_length = 40000, 
      preview_config = {

        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          opts.desc = opts.desc and ('GS: ' .. opts.desc) 
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', 'gn', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr = true, desc = "Next Hunk"})

        map('n', 'gp', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr = true, desc = "Previous Hunk"})

        -- Actions
        map({'n', 'v'}, '<leader>hs', gs.stage_hunk, {desc = "Stage Hunk"})
        map({'n', 'v'}, '<leader>hr', gs.reset_hunk, {desc = "Reset Hunk"})
        map('n', '<leader>gS', gs.stage_buffer, {desc = "Stage Buffer"})
        map('n', '<leader>gR', gs.reset_buffer, {desc = "Reset Buffer"})
        map('n', '<leader>gu', gs.undo_stage_hunk, {desc = "Undo Stage Hunk"})
        map('n', '<leader>gp', gs.preview_hunk, {desc = "Preview Hunk"})
        map('n', '<leader>gb', function() gs.blame_line{full=true} end, {desc = "Blame Line (Full)"})
        map('n', '<leader>gB', gs.toggle_current_line_blame, {desc = "Toggle Current Line Blame"})
        map('n', '<leader>gd', gs.diffthis, {desc = "Diff This ~ Local"}) -- Diff against index
        map('n', '<leader>gD', function() gs.diffthis('~') end, {desc = "Diff This ~ HEAD"}) -- Diff against last commit (HEAD)

        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = "Select Hunk (Inner Hunk text object)"})
      end
    }
  },

  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "LspStart", "LspStop", "LspRestart" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          'typescript-language-server',
          'eslint'
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
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
            { name = "buffer" },
            { name = "path" },
          }),
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
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  }, -- Corrected comma placement

  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon",
        transparent = false,
      })
      vim.cmd.colorscheme "tokyonight"
    end,
  },

  -- Terminal Manager
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
        return 20
      end,
      open_mapping = [[<c-\>]], -- Be mindful of this mapping
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
      }
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
    opts = {
      -- your which-key custom options
    }
  }
})

