local M = {}

M.setup_lsp = function(attach, capabilities)
   local lspconfig = require "lspconfig"

   lspconfig.html.setup {
      on_attach = attach,
      capabilities = capabilities,
   }
  lspconfig.tsserver.setup {
    cmd = {
      "typescript-language-server", "--stdio"
    },
    filetypes = {"typescriptreact", "typescript.tsx"},
    root_dir = root_pattern("package.json", "tsconfig.json")
  }
end

return M
