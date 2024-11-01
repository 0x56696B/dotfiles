-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'markdown',
--   callback = function()
--     vim.opt_local.wrap = false
--     vim.opt_local.wrap = false
--   end,
-- })

-- NOTE: Disabled
if true then
  return {};
end

return {
  { import = 'lazyvim.plugins.extras.lang.markdown' },
}
