-- vim.filetype.add({
--   extension = {
--     env = "dotenv",
--   },
--   filename = {
--     [".env*"] = "dotenv",
--   },
--   pattern = {
--     -- INFO: Match filenames like - ".env.example", ".env.local" and so on
--     ["%.env%.[%w_.-]+"] = "dotenv",
--   },
-- })
--

return {
  { import = 'lazyvim.plugins.extras.util.dot' },
}
