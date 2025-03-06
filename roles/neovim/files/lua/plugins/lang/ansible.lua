-- NOTE: Disabled
if true then
  return {}
end

local treesitter = { "yaml" }
local mason = { "ansiblels", "ansible_lint", "yamllint" }

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml.ansible" },
  desc = "ansible commentstring configuration",
  command = "setlocal commentstring=#\\ %s",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*/playbooks/*.yml" },
  desc = "ansible detect ansible file type",
  command = "set filetype=yaml.ansible"
})

return {
  {
    "pearofducks/ansible-vim",
    ft = "yaml.ansible",
    opts = {}
  },

  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = treesitter }
  },

    -- Install LSPs and Linters
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = mason },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ansiblels = {},
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["yaml.ansible"] = { "ansible_lint", "yamllint" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["yaml.ansible"] = { "yamlfix" },
      },
    },
  },
}
