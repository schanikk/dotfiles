-- Renders markdown in the buffer: headings, code blocks, checkboxes, tables,
-- quotes, etc. See `:help render-markdown`
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ---@module 'render-markdown'
    ---@type render.md.UserOpts
    opts = {},
  },
}
