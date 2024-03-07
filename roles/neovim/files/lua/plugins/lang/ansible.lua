-- NOTE: Disabled
if true then
  return {}
end

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

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "yaml",
        })
      end
    end,
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
