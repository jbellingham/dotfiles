-- This is where you custom modules and plugins goes.
-- See the wiki for a guide on how to extend NvChad
local hooks = require "core.hooks"

-- NOTE: To use this, make a copy with `cp example_init.lua init.lua`

--------------------------------------------------------------------

-- To modify packaged plugin configs, use the overrides functionality
-- if the override does not exist in the plugin config, make or request a PR,
-- or you can override the whole plugin config with 'chadrc' -> M.plugins.default_plugin_config_replace{}
-- this will run your config instead of the NvChad config for the given plugin

-- hooks.override("lsp", "publish_diagnostics", function(current)
--   current.virtual_text = false;
--   return current;
-- end)

-- To add new mappings, use the "setup_mappings" hook,
-- you can set one or many mappings
-- example below:

-- hooks.add("setup_mappings", function(map)
--    map("n", "<leader>cc", "gg0vG$d", opt) -- example to delete the buffer
--    .... many more mappings ....
-- end)

hooks.add("setup_mappings", function(map)
   map("n", "<leader>tconf", ":e ~/.tmux.conf<cr>")
   map("n", "<leader>conf", ":e ~/.config/nvim/lua/custom/init.lua <cr>")
   -- map("n", "<leader>qf", "<Plug>(coc-fix-current)")
   -- todo: fix this ^
   map("n", "<leader>qf", ":CocCommand tsserver.executeAutofix <cr>")
   -- map("n", "<leader>rn", "<Plug>(coc-rename)")
-- nmap <leader>rn <Plug>(coc-rename)
end)

-- To add new plugins, use the "install_plugin" hook,
-- NOTE: we heavily suggest using Packer's lazy loading (with the 'event' field)
-- see: https://github.com/wbthomason/packer.nvim
-- examples below:

-- hooks.add("install_plugins", function(use)
--    use {
--       "max397574/better-escape.nvim",
--       event = "InsertEnter",
--    }
-- end)

hooks.add("install_plugins", function(use)
    use {
      'neoclide/coc.nvim',
      branch = 'release',
      after = "nvim-lspconfig",
      config = function()
        require("custom.coc-config")
      end,
    }
    use {'tpope/vim-fugitive'}
    use {'airblade/vim-gitgutter'}
    use {'sudormrfbin/cheatsheet.nvim'}
    use {'tpope/vim-obsession'}
    -- use {
    --   "jose-elias-alvarez/null-ls.nvim",
    --   -- load it after nvim-lspconfig , since we'll use some lspconfig stuff in null-ls config!
    --   after = "nvim-lspconfig",
    --   config = function()
    --      require("custom.plugin_confs.null-ls").setup()
    --   end,
   -- }

end)

-- end)
-- alternatively, put this in a sub-folder like "lua/custom/plugins/mkdir"
-- then source it with

-- require "custom.plugins.mkdir"

