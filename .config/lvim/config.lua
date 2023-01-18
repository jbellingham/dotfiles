-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.format_on_save = true
lvim.lint_on_save = true
lvim.colorscheme = "tokyonight"
vim.opt.foldmethod = "syntax"

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- lvim.keys.normal_mode["S"] = ":require('spectre').open()<CR>"
-- lvim.keys.normal_mode[""] = ":require('spectre').open()<CR>"
-- nnoremap <leader>S :lua require('spectre').open()<CR>

-- "search current word
-- nnoremap <leader>sw :lua require('spectre').open_visual({select_word=true})<CR>
-- vnoremap <leader>s :lua require('spectre').open_visual()<CR>
-- "  search in current file
-- nnoremap <leader>sp viw:lua require('spectre').open_file_search()<cr>

-- add your own keymapping
lvim.keys.normal_mode["<Leader>tconf"] = ":e ~/.tmux.conf<cr>"

-- buffer management
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<Leader>x"] = ":BufferClose<cr>"
lvim.keys.normal_mode["<Tab>"] = ":BufferNext<cr>"
lvim.keys.normal_mode["<S-Tab>"] = ":BufferPrevious<cr>"

lvim.keys.normal_mode["<C-n>"] = ":NvimTreeToggle<cr>"
-- insert mode movement
lvim.keys.insert_mode["<C-h>"] = "<Left>"
lvim.keys.insert_mode["<C-l>"] = "<Right>"
lvim.keys.insert_mode["<C-j>"] = "<Down>"
lvim.keys.insert_mode["<C-k>"] = "<Up>"
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = ""
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"
lvim.keys.normal_mode["<Leader>f"] = ""
lvim.keys.normal_mode["<Leader>ff"] = ":Telescope find_files<cr>"
lvim.keys.normal_mode["<Leader>fg"] = ":Telescope live_grep<cr>"
lvim.keys.normal_mode["<Leader>fb"] = ":Telescope buffers<cr>"
lvim.keys.normal_mode["<Leader>fh"] = ":Telescope help_tags<cr>"
-- lvim.keys.normal_mode["<Leader>sw"] = ":lua require('spectre').open_visual({select_word=true})<CR>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
lvim.builtin.telescope.on_config_done = function()
  local actions = require "telescope.actions"
  -- for input mode
  lvim.builtin.telescope.defaults.mappings.i["<C-j>"] = actions.move_selection_next
  lvim.builtin.telescope.defaults.mappings.i["<C-k>"] = actions.move_selection_previous
  lvim.builtin.telescope.defaults.mappings.i["<C-n>"] = actions.cycle_history_next
  lvim.builtin.telescope.defaults.mappings.i["<C-p>"] = actions.cycle_history_prev
  -- for normal mode
  lvim.builtin.telescope.defaults.mappings.n["<C-j>"] = actions.move_selection_next
  lvim.builtin.telescope.defaults.mappings.n["<C-k>"] = actions.move_selection_previous
end

-- Use which-key to add extra bindings with the leader-key prefix
-- nnoremap <leader>S :lua require('spectre').open()<CR>

-- "search current word
-- nnoremap <leader>sw :lua require('spectre').open_visual({select_word=true})<CR>
-- vnoremap <leader>s :lua require('spectre').open_visual()<CR>
-- "  search in current file
-- nnoremap <leader>sp viw:lua require('spectre').open_file_search()<cr>

lvim.builtin.which_key.mappings["s"]["s"] = { ":lua require('spectre').open_visual()<CR>", "Open visual spectre search"}
lvim.builtin.which_key.mappings["s"]["w"] = { ":lua require('spectre').open_visual({select_word=true})<CR>", "Search for word" }
lvim.builtin.which_key.mappings["s"]["f"] = { "viw:lua require('spectre').open_file_search()<cr>", "Search in file"}
lvim.builtin.which_key.mappings["S"] = { ":lua require('spectre').open()<CR>", "Open spectre search" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnosticss" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnosticss" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.nvimtree.hide_dotfiles = 0

-- lvim.builtin.bufferline.
-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {}
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

lvim.builtin.dap.active = true
-- generic LSP settings
-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end
-- you can overwrite the null_ls setup table (useful for setting the root_dir function)
-- lvim.lsp.null_ls.setup = {
--   root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
-- }
-- or if you need something more advanced
-- lvim.lsp.null_ls.setup.root_dir = function(fname)
--   if vim.bo.filetype == "javascript" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "node_modules")(fname)
--       or require("lspconfig/util").path.dirname(fname)
--   elseif vim.bo.filetype == "php" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "composer.json")(fname) or vim.fn.getcwd()
--   else
--     return require("lspconfig/util").root_pattern("Makefile", ".git")(fname) or require("lspconfig/util").path.dirname(fname)
--   end
-- end

-- set a formatter if you want to override the default lsp one (if it exists)
-- lvim.lang.typescript.formatters = {{exe = "prettierd"}}
-- lvim.lang.tsx.formatters = lvim.lang.typescript.formatters
-- lvim.lang.typescriptreact.formatters = lvim.lang.typescript.formatters
-- lvim.lang.typescript.linters = { { exe = "eslint" } }
-- lvim.lang.typescriptreact.linters = lvim.lang.typescript.linters
-- lvim.lang.typescriptreact.lsp = {
--   cmd = { "typescript-language-server", "--stdio" };
--   filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" };
-- }
-- lvim.lsp.override = { "typescriptreact" }
-- lvim.lang.typescriptreact.
-- lvim.lang.typescript.lsp.setup = {
--   filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" }}
-- lvim.lang.python.formatters = {
--   {
--     exe = "black",
--     args = {}
--   }
-- }
-- set an additional linter
-- lvim.lang.python.linters = {
--   {
--     exe = "flake8",
--     args = {}
--   }
-- }
-- Additional Plugins
lvim.plugins = {
  { "tpope/vim-fugitive", event= "BufEnter" },
  { "tpope/vim-obsession", event = "VimEnter" },
  { "tpope/vim-surround", event = "BufEnter" },
  {
      "neoclide/coc.nvim",
      branch = "release",
      event = "VimEnter",
      config = function()
        require("user.coc-config")
      end
  },
  {
    'sudormrfbin/cheatsheet.nvim',
    event = 'BufRead'
  },
  {"folke/tokyonight.nvim"},
  {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  },
}
-- lvim.plugins = {
--     {"folke/tokyonight.nvim"}, {
--         "ray-x/lsp_signature.nvim",
--         config = function() require"lsp_signature".on_attach() end,
--         event = "InsertEnter"
--     }
-- }

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
-- Highlight the symbol and its references when holding the cursor.
lvim.autocommands.custom_groups = {
  { "BufRead", "*", "normal zR" }
}
