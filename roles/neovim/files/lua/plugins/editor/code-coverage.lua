local uv = vim.uv or vim.loop

local function is_dir(path)
  local st = uv.fs_stat(path)
  return st and st.type == "directory"
end

local function is_file(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "file"
end
local function normalize(path)
  -- normalize for safe equality comparisons across platforms
  return vim.fs.normalize(path)
end

local function git_root(start_dir)
  local git = vim.fs.find(".git", {
    path = start_dir,
    upward = true,
    type = "directory",
    limit = 1,
  })[1]

  return git and vim.fs.dirname(git) or nil
end

-- Recursively search *inside* coverage/ for any lcov/info file
local function find_lcov_recursive(coverage_dir)
  local matches = vim.fs.find(function(name, path)
    if not is_file(path) then
      return false
    end
    return name:match "%.lcov$" or name:match "%.info$"
  end, {
    path = coverage_dir,
    type = "file",
  })

  -- Return the first match (deterministic ordering from vim.fs.find)
  return matches[1]
end

local function find_lcov_coverage_file(bufnr)
  bufnr = bufnr or 0

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start_dir = (bufname ~= "" and vim.fs.dirname(bufname)) or uv.cwd()

  local repo_root = git_root(start_dir)
  if not repo_root then
    return nil
  end

  local repo_root_n = normalize(repo_root)

  for dir in vim.fs.parents(start_dir) do
    local coverage_dir = dir .. "/coverage"

    if is_dir(coverage_dir) then
      -- coverage/ found → search recursively, then STOP
      return find_lcov_recursive(coverage_dir)
    end

    if normalize(dir) == repo_root_n then
      break
    end
  end

  return nil
end

return {
  {
    "andythigpen/nvim-coverage",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      auto_reload = true,
      lcov_file = function()
        return find_lcov_coverage_file(0)
      end,
    },
    keys = {
      {
        "<leader>cp",
        function()
          require("coverage").load(true)
          require("coverage").toggle()
        end,
        desc = "Toggle Coverage",
        mode = "n",
      },
      {
        "<leader>cP",
        function()
          require("coverage").load(true)
          require("coverage").summary()
        end,
        desc = "Toggle Coverage Summary",
        mode = "n",
      },
    },
  },
}
