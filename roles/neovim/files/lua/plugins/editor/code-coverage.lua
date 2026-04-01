-- lua/plugins/coverage.lua
local uv = vim.uv or vim.loop

-- Cache structure:
-- {
--   [git_root] = {
--     { sroot = "/abs/path/to/service", lcov = "/abs/path/to/lcov.info" },
--     ...
--   }
-- }
-- Keyed by git root so monorepos with multiple services share one traversal.
-- Persists for the lifetime of the Neovim session.
local lcov_cache = {}

local coverage_loaded = false
local watcher = nil
local watched_path = nil

local function service_root_of(file_path)
  local dir = vim.fs.normalize(vim.fs.dirname(file_path))

  while dir do
    local parent = vim.fs.normalize(vim.fs.dirname(dir))

    if parent == dir then
      return nil
    end

    if not vim.fs.basename(parent):match "coverage" and not vim.fs.basename(parent):match "report" then
      return parent
    end

    dir = parent
  end
  return nil
end

local function git_root(start_dir)
  local git = vim.fs.find(".git", {
    path = start_dir,
    upward = true,
    limit = 1,
  })[1]

  return git and vim.fs.normalize(vim.fs.dirname(git)) or nil
end

local function build_cache(root)
  local all = vim.fs.find(function(name, _)
    return name == "lcov.info" or name:match "%.lcov$"
  end, { path = root, type = "file", limit = math.huge })

  local entries = {}
  for _, f in ipairs(all) do
    local sroot = service_root_of(f)

    table.insert(entries, { sroot = sroot or root, lcov = f })
  end

  lcov_cache[root] = entries
  return entries
end

local function find_lcov_for_buf(bufnr)
  bufnr = bufnr or 0

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local buf_dir = vim.fs.normalize(bufname ~= "" and vim.fs.dirname(bufname) or uv.cwd())

  local root = git_root(buf_dir)
  if not root then
    return nil
  end

  -- Use cached entries if available, otherwise traverse and cache.
  local entries = lcov_cache[root] or build_cache(root)

  if #entries == 0 then
    return nil
  end
  if #entries == 1 then
    return entries[1].lcov
  end

  -- Pick the entry whose service root is the deepest ancestor of buf_dir.
  local best, best_len = nil, -1
  local buf_dir_slash = buf_dir .. "/"

  for _, entry in ipairs(entries) do
    local sroot_prefix = entry.sroot .. "/"
    if vim.startswith(buf_dir_slash, sroot_prefix) and #entry.sroot > best_len then
      best, best_len = entry.lcov, #entry.sroot
    end
  end

  return best or entries[1].lcov
end

local function stop_watcher()
  if watcher then
    watcher:stop()
    watcher:close()
    watcher = nil
    watched_path = nil
  end
end

local function start_watcher(path)
  if watched_path == path then
    return
  end
  stop_watcher()

  local handle = uv.new_fs_event()
  if not handle then
    return
  end

  handle:start(path, {}, function(err, _, events)
    if err then
      return
    end
    if events.change or events.rename then
      vim.schedule(function()
        require("coverage").load_lcov(path, true)
      end)
    end
  end)

  watcher = handle
  watched_path = path
end

local function load_lcov(show)
  local path = find_lcov_for_buf(0)

  if not path then
    vim.notify("nvim-coverage: no lcov file found for this buffer", vim.log.levels.WARN)
    return
  end

  require("coverage").load_lcov(path, show)
  vim.notify("nvim-coverage: coverage found for path: " .. path, vim.log.levels.INFO)

  coverage_loaded = true

  start_watcher(path)
end

local function toggle_coverage()
  if not coverage_loaded then
    load_lcov(true)
  else
    require("coverage").toggle()
  end
end

local function toggle_summary()
  if not coverage_loaded then
    load_lcov(true)
  end

  require("coverage").summary()
end

return {
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = {
        covered = { hl = "CoverageCovered", text = "▌" },
        uncovered = { hl = "CoverageUncovered", text = "▌" },
        partial = { hl = "CoveragePartial", text = "▌" },
      },
      summary = { min_coverage = 80.0 },
    },
    keys = {
      {
        "<leader>tc",
        toggle_coverage,
        desc = "Toggle Coverage",
        mode = "n",
      },
      {
        "<leader>tC",
        toggle_summary,
        desc = "Coverage Summary",
        mode = "n",
      },
      {
        -- Escape hatch: if you add a new service mid-session and need
        -- the traversal to pick it up, invalidate the cache manually.
        "<leader>tX",
        function()
          lcov_cache = {}
          coverage_loaded = false
          stop_watcher()
          vim.notify("nvim-coverage: cache cleared", vim.log.levels.INFO)
        end,
        desc = "Coverage Clear Cache",
        mode = "n",
      },
    },
    config = function(_, opts)
      require("coverage").setup(opts)

      vim.api.nvim_set_hl(0, "CoverageCovered", { fg = "#98c379", default = true })
      vim.api.nvim_set_hl(0, "CoverageUncovered", { fg = "#e06c75", default = true })
      vim.api.nvim_set_hl(0, "CoveragePartial", { fg = "#e5c07b", default = true })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        once = true,
        callback = stop_watcher,
      })
    end,
  },
}

--
-- local uv = vim.uv or vim.loop
--
-- local function service_root_of(file_path)
--   local dir = vim.fs.normalize(vim.fs.dirname(file_path))
--
--   while dir do
--     local parent = vim.fs.normalize(vim.fs.dirname(dir))
--
--     if parent == dir then
--       return nil
--     end
--
--     if not vim.fs.basename(parent):match "coverage" and not vim.fs.basename(parent):match "report" then
--       return parent
--     end
--
--     dir = parent
--   end
--
--   return nil
-- end
--
-- local function git_root(start_dir)
--   local git = vim.fs.find(".git", {
--     path = start_dir,
--     upward = true,
--     limit = 1,
--   })[1]
--
--   return git and vim.fs.normalize(vim.fs.dirname(git)) or nil
-- end
--
-- local function find_lcov_for_buf(bufnr)
--   bufnr = bufnr or 0
--
--   local bufname = vim.api.nvim_buf_get_name(bufnr)
--   local buf_dir = vim.fs.normalize(bufname ~= "" and vim.fs.dirname(bufname) or uv.cwd())
--
--   local root = git_root(buf_dir)
--   if not root then
--     return nil
--   end
--
--   local all = vim.fs.find(function(name, _)
--     return name == "lcov.info" or name:match "%.lcov$"
--   end, { path = root, type = "file", limit = math.huge })
--
--   if #all == 0 then
--     return nil
--   end
--
--   if #all == 1 then
--     return all[1]
--   end
--
--   local best, best_len = nil, -1
--   for _, f in ipairs(all) do
--     local sroot = service_root_of(f)
--
--     if sroot then
--       local sroot_prefix = sroot .. "/"
--       local buf_dir_slash = buf_dir .. "/"
--
--       if vim.startswith(buf_dir_slash, sroot_prefix) and #sroot > best_len then
--         best, best_len = f, #sroot
--       end
--     end
--   end
--
--   return best or all[1]
-- end
--
-- local function load_lcov(show)
--   local path = find_lcov_for_buf(0)
--   if not path then
--     vim.notify("nvim-coverage: no lcov file found for this buffer", vim.log.levels.WARN)
--     return
--   end
--
--   require("coverage").load_lcov(path, show)
-- end
--
-- return {
--   {
--     "andythigpen/nvim-coverage",
--     dependencies = { "nvim-lua/plenary.nvim" },
--     opts = {
--       -- auto_reload watches the file path returned by lcov_file — not used
--       -- by load_lcov, so we manage reloading explicitly via keymaps instead
--       signs = {
--         covered = { hl = "CoverageCovered", text = "▌" },
--         uncovered = { hl = "CoverageUncovered", text = "▌" },
--         partial = { hl = "CoveragePartial", text = "▌" },
--       },
--       summary = { min_coverage = 80.0 },
--     },
--     keys = {
--       {
--         "<leader>tc",
--         function()
--           load_lcov(true)
--         end,
--         desc = "Toggle Coverage",
--         mode = "n",
--       },
--       {
--         "<leader>tC",
--         function()
--           load_lcov(false)
--           require("coverage").summary()
--         end,
--         desc = "Coverage Summary",
--         mode = "n",
--       },
--     },
--     config = function(_, opts)
--       require("coverage").setup(opts)
--
--       vim.api.nvim_set_hl(0, "CoverageCovered", { fg = "#98c379", default = true })
--       vim.api.nvim_set_hl(0, "CoverageUncovered", { fg = "#e06c75", default = true })
--       vim.api.nvim_set_hl(0, "CoveragePartial", { fg = "#e5c07b", default = true })
--     end,
--   },
-- }
