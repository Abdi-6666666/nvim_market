local M = {}
local api = vim.api
local fn = vim.fn

-- 配置
M.config = {
  width = 0.85,
  height = 0.8,
  border = 'rounded',
  title = ' Neovim 插件市场(GitHub) '
}

M.state = {
  page = 1,
  list = {},
  loading = false,
  buf = nil,
  win = nil,
  category = 'nvim+plugin',
  categories = {
    'nvim+plugin',
    'nvim+plugin+theme',
    'nvim+plugin+ai',
    'nvim+plugin+ui',
    'nvim+plugin+editor',
    'nvim+plugin+tool',
  },
  cat_names = {
    '📦 全部',
    '🎨 主题',
    '🤖 AI',
    '🪟 UI',
    '✏️ 编辑器',
    '🛠️ 工具'
  }
}

-- 打开浮窗
function M.open()
  if M.state.buf and api.nvim_buf_is_valid(M.state.buf) then
    api.nvim_win_set_buf(M.state.win, M.state.buf)
    return
  end

  local buf = api.nvim_create_buf(false, true)
  M.state.buf = buf

  local ui = api.nvim_list_uis()[1]
  local width = math.floor(ui.width * M.config.width)
  local height = math.floor(ui.height * M.config.height)
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  local win = api.nvim_open_win(buf, true, {
    title = M.config.title,
    title_pos = 'center',
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    border = M.config.border,
    style = 'minimal'
  })

  M.state.win = win
  M.state.page = 1
  M.state.list = {}

  vim.bo[buf].filetype = 'nvim_market'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].number = false

  M.setup_keymap()
  M.fetch()
end

-- 拉取 GitHub API
function M.fetch()
  if M.state.loading then return end
  M.state.loading = true
  M.render_loading()

  local url = string.format(
    'https://api.github.com/search/repositories?q=%s&sort=stars&order=desc&per_page=20&page=%d',
    M.state.category,
    M.state.page
  )

  local cmd = vim.fn.has('win32') == 1
    and 'curl -s "' .. url .. '"'
    or 'curl -s \'' .. url .. '\''

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local ok, res = pcall(vim.json.decode, table.concat(data, ''))
      if ok and res.items then
        vim.list_extend(M.state.list, res.items)
        M.render()
        M.state.page = M.state.page + 1
      end
      M.state.loading = false
    end
  })
end

-- 渲染列表
function M.render()
  local buf = M.state.buf
  if not buf or not api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  local cat = M.state.cat_names[vim.fn.index(M.state.categories, M.state.category) + 1]
  table.insert(lines, ' 分类: ' .. cat .. '  |  滚动加载更多  | 回车打开README')
  table.insert(lines, '')

  for _, item in ipairs(M.state.list) do
    local name = item.name or ''
    local star = tostring(item.stargazers_count or 0)
    local author = item.owner and item.owner.login or ''
    local desc = item.description or '无描述'
    desc = desc:sub(1, 60)

    local line = string.format(
      '  %-25s  %-18s ⭐ %-5s | %s',
      name,
      author,
      star,
      desc
    )
    table.insert(lines, line)
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
end

function M.render_loading()
  local buf = M.state.buf
  api.nvim_buf_set_lines(buf, 0, -1, false, { ' 加载中... 从 GitHub 获取插件' })
end

-- 快捷键
function M.setup_keymap()
  local buf = M.state.buf

  vim.keymap.set('n', '<CR>', function()
    local idx = vim.fn.line('.') - 3
    local item = M.state.list[idx + 1]
    if item then
      fn.jobstart('start "' .. item.html_url .. '#readme"')
    end
  end, { buffer = buf, desc = '打开README' })

  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf })

  vim.keymap.set('n', '1', function() M.set_cat(1) end, { buffer = buf })
  vim.keymap.set('n', '2', function() M.set_cat(2) end, { buffer = buf })
  vim.keymap.set('n', '3', function() M.set_cat(3) end, { buffer = buf })
  vim.keymap.set('n', '4', function() M.set_cat(4) end, { buffer = buf })
  vim.keymap.set('n', '5', function() M.set_cat(5) end, { buffer = buf })
  vim.keymap.set('n', '6', function() M.set_cat(6) end, { buffer = buf })

  local group = api.nvim_create_augroup('NvimMarketScroll', { clear = true })
  api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = buf,
    callback = function()
      local line = vim.fn.line('$')
      local cur = vim.fn.line('.')
      if cur > line - 5 and not M.state.loading then
        M.fetch()
      end
    end
  })
end

function M.set_cat(idx)
  M.state.category = M.state.categories[idx]
  M.state.list = {}
  M.state.page = 1
  M.fetch()
end

return M
