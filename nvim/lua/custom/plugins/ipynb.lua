-- Jupyter notebooks in Neovim. See `:help ipynb` and `:checkhealth ipynb`

local function is_exec(p)
  return vim.fn.executable(p) == 1
end

local function read_pyright_venv(file)
  local venv, venv_path, in_section = nil, '.', false
  for line in io.lines(file) do
    local header = line:match '^%s*%[([^%]]*)%]'
    if header then
      in_section = header == 'tool.pyright'
    elseif in_section then
      venv = line:match '^%s*venv%s*=%s*["\']([^"\']+)["\']' or venv
      venv_path = line:match '^%s*venvPath%s*=%s*["\']([^"\']+)["\']' or venv_path
    end
  end
  return venv, venv_path
end

local poetry_cache = {} -- dir -> python path or false

-- Nearest project venv for a notebook, like pyright: .venv, [tool.pyright], Poetry
local function resolve_python(path)
  local dir = vim.fs.dirname(vim.fn.fnamemodify(path, ':p'))
  while dir do
    for _, name in ipairs { '.venv', 'venv' } do
      local py = dir .. '/' .. name .. '/bin/python'
      if is_exec(py) then
        return py
      end
    end

    local pyproject = dir .. '/pyproject.toml'
    if vim.uv.fs_stat(pyproject) then
      local ok, venv, venv_path = pcall(read_pyright_venv, pyproject)
      if ok and venv then
        local py = vim.fs.normalize(dir .. '/' .. venv_path .. '/' .. venv .. '/bin/python')
        if is_exec(py) then
          return py
        end
      end
    end

    if vim.uv.fs_stat(dir .. '/poetry.lock') then
      if poetry_cache[dir] == nil then
        poetry_cache[dir] = false
        if vim.fn.executable 'poetry' == 1 then
          local res = vim.system({ 'poetry', 'env', 'info', '-p' }, { cwd = dir, text = true }):wait(5000)
          local venv = res.code == 0 and vim.trim(res.stdout or '') or ''
          if venv ~= '' and is_exec(venv .. '/bin/python') then
            poetry_cache[dir] = venv .. '/bin/python'
          end
        end
      end
      if poetry_cache[dir] then
        return poetry_cache[dir]
      end
    end

    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

return {
  {
    'ajbucci/ipynb.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'neovim/nvim-lspconfig',
      'nvim-tree/nvim-web-devicons', -- language icons in cell borders
      'folke/snacks.nvim', -- inline images
    },
    opts = {},
    config = function(_, opts)
      require('ipynb').setup(opts)
      -- Per-notebook kernel Python; nil falls back to the plugin's own discovery
      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('ipynb-python-resolver', { clear = true }),
        pattern = '*.ipynb',
        callback = function(args)
          local cfg = require('ipynb.config').get()
          cfg.kernel = cfg.kernel or {}
          cfg.kernel.python_path = resolve_python(vim.api.nvim_buf_get_name(args.buf))
        end,
      })
    end,
  },
  { -- Only the image module is enabled; it renders notebook output images
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      image = { enabled = true },
    },
  },
}
