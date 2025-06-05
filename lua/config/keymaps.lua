-- ~/.config/nvim/lua/config/keymaps.lua
-- Set leader key
vim.g.mapleader = " "

-- Basic keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Telescope file navigation
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent files" })

-- Telescope search (fuzzy variants)
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Search text (fuzzy)" })
vim.keymap.set("n", "<leader>fs", ":Telescope grep_string<CR>", { desc = "Find string under cursor (fuzzy)" })

-- Telescope Git
vim.keymap.set("n", "<leader>gs", ":Telescope git_status<CR>", { desc = "Git status" })

-- Telescope search (exact variants)
vim.keymap.set("n", "<leader>fG", function()
  require("telescope.builtin").live_grep({
    additional_args = function() return { "--word-regexp" } end
  })
end, { desc = "Search text (exact words)" })

vim.keymap.set("n", "<leader>fS", function()
  require("telescope.builtin").grep_string({
    word_match = "-w"
  })
end, { desc = "Find exact word under cursor" })

-- Literal string search (no regex)
vim.keymap.set("n", "<leader>fl", function()
  require("telescope.builtin").live_grep({
    additional_args = function() return { "--fixed-strings" } end
  })
end, { desc = "Search literal string" })

-- LSP + Telescope integration
vim.keymap.set("n", "<leader>lr", ":Telescope lsp_references<CR>", { desc = "Find references" })
vim.keymap.set("n", "<leader>ls", ":Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>lw", ":Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>ld", ":Telescope lsp_definitions<CR>", { desc = "Find definitions" })
vim.keymap.set("n", "<leader>li", ":Telescope lsp_implementations<CR>", { desc = "Find implementations" })

-- Word deletion in insert mode
vim.keymap.set("i", "<A-BS>", "<C-w>", { desc = "Delete word backwards" })
vim.keymap.set("i", "<A-Del>", "<C-o>dw", { desc = "Delete word forwards" })
vim.keymap.set("i", "<C-Delete>", "<Esc>dw<Cmd>startinsert<CR>", { desc = "Delete word forward" })
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" }) -- BS for Backspace

-- toggleterm
-- vim.keymap.set('n', '<leader>tf', "<cmd>ToggleTerm direction=float<cr>", {desc = "ToggleTerm (Float)"})
-- vim.keymap.set('n', '<leader>th', "<cmd>ToggleTerm direction=horizontal<cr>", {desc = "ToggleTerm (Horizontal)"})
-- vim.keymap.set('n', '<leader>tv', "<cmd>ToggleTerm direction=vertical<cr>", {desc = "ToggleTerm (Vertical)"})
vim.keymap.set("n", "<leader>t1", "<cmd>ToggleTerm id='1' direction=float<cr>", { desc = "Toggle Terminal 1 (Float)"})
vim.keymap.set("n", "<leader>t2", "<cmd>ToggleTerm id='2' direction=vertical size=90<cr>", { desc = "Toggle Terminal 2 (Vertical)"})


-- comment
vim.keymap.set("n", "<C-_>", "<Plug>(comment_toggle_linewise_current)", { noremap = false, desc = "Toggle Comment (Current Line)" })
vim.keymap.set("v", "<C-_>", "<Plug>(comment_toggle_linewise_visual)", { noremap = false, desc = "Toggle Comment (Selection)" })



