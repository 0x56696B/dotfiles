return {
  'williamboman/mason.nvim',
  dependencies = { 'Zeioth/mason-extra-cmds', opts = {} },
  cmd = {
    'Mason',
    'MasonInstall',
    'MasonUninstall',
    'MasonUninstallAll',
    'MasonLog',
    'MasonUpdate',
    'MasonUpdateAll', -- provided by `Zeioth/mason-extra-cmds` to headlessly update packages
  },
}
