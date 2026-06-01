local M = {}
local api = vim.api
local fn = vim.fn

-- 配置
M.config = {
  width = 0.85,
  height = 0.8,
  border = 'rounded',
  title = ' Neovim 插件市场(GitHub) ',
  github_token = os.getenv('GITHUB_TOKEN'), -- 支持从环境变量读取 token
  timeout = 10, -- API 请求超时时间（秒）
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
  -- 检查缓冲区和窗口是否都有效
  local buf_valid = M.state.buf and api.nvim_buf_is_valid(M.state.buf)
  local win_valid = M.state.win and api.nvim_win_is_valid(M.state.win)
  
  if buf_valid and win_valid then
    api.nvim_set_current_win(M.state.win)
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

-- 渲染错误信息
function M.render_error(error_msg)
  local buf = M.state.buf
  if not buf or not api.nvim_buf_is_valid(buf) then return end

  local lines = {
    ' ❌ 加载失败',
    '',
    ' 错误信息: ' .. error_msg,
    '',
    ' 可能的原因:',
    '   • GitHub API 速率限制 (未认证请求: 60/小时)',
    '   • 网络连接问题',
    '   • API 服务暂时不可用',
    '',
    ' 解决方案:',
    '   • 设置环境变量: export GITHUB_TOKEN=<your_token>',
    '   • 检查网络连接',
    '   • 稍后重试 (按 r 重新加载)',
  }

  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_add_highlight(buf, -1, 'ErrorMsg', 0, 1, -1)
end

-- 拉取 GitHub API（改进版本）
function M.fetch()
  if M.state.loading then return end
  M.state.loading = true
  M.render_loading()

  local url = string.format(
    'https://api.github.com/search/repositories?q=%s&sort=stars&order=desc&per_page=20&page=%d',
    M.state.category,
    M.state.page
  )

  -- 构建 curl 命令，支持认证和超时
  local curl_cmd = 'curl'
  
  -- Windows 和其他系统的命令构建差异
  local is_win = vim.fn.has('win32') == 1
  
  -- 构建参数
  local args = {
    '-s', -- 静默模式
    '--max-time', tostring(M.config.timeout), -- 设置超时
    '--connect-timeout', '5', -- 连接超时
  }
  
  -- 如果有 GitHub token，添加认证头
  if M.config.github_token then
    table.insert(args, '-H')
    table.insert(args, 'Authorization: token ' .. M.config.github_token)
  end
  
  table.insert(args, url)
  
  -- 组装最终命令
  local cmd
  if is_win then
    cmd = curl_cmd .. ' ' .. table.concat(args, ' ')
  else
    -- Unix/Linux: 正确处理 token 中的特殊字符
    cmd = curl_cmd
    for _, arg in ipairs(args) do
      if arg:match('[%s$"\'`]') then
        cmd = cmd .. ' "' .. arg:gsub('"', '\\"') .. '"'
      else
        cmd = cmd .. ' ' .. arg
      end
    end
  end

  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then
        M.state.loading = false
        M.render_error('API 返回空数据')
        return
      end

      local response = table.concat(data, '')
      
      -- 检查是否为空响应
      if response == '' then
        M.state.loading = false
        M.render_error('网络请求失败，请检查连接')
        return
      end

      local ok, res = pcall(vim.json.decode, response)
      
      if not ok then
        M.state.loading = false
        M.render_error('JSON 解析失败: ' .. tostring(res))
        return
      end

      -- 检查 API 错误响应
      if res.message then
        M.state.loading = false
        M.render_error('GitHub API 错误: ' .. res.message)
        return
      end

      if res.items and #res.items > 0 then
        vim.list_extend(M.state.list, res.items)
        M.render()
        M.state.page = M.state.page + 1
      else
        M.state.loading = false
        if M.state.page == 1 then
          M.render_error('未找到相关插件')
        else
          -- 已加载所有结果
          M.render()
        end
      end
      
      M.state.loading = false
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        -- 修复：去除换行符，只取第一行错误信息
        local error_msg = data[1] or ''
        error_msg = error_msg:gsub('\n', ' '):gsub('\r', '')  -- 清除换行符
        M.render_error('网络错误: ' .. error_msg)
      end
      M.state.loading = false
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 and M.state.loading then
        M.state.loading = false
        M.render_error('请求超时或连接失败 (退出码: ' .. exit_code .. ')')
      end
    end
  })

  if job_id <= 0 then
    M.state.loading = false
    M.render_error('无法启动 curl 进程，请确保已安装 curl')
  end
end

-- 渲染列表
function M.render()
  local buf = M.state.buf
  if not buf or not api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  local cat = M.state.cat_names[vim.fn.index(M.state.categories, M.state.category) + 1]
  table.insert(lines, ' 分类: ' .. cat .. '  |  滚动加载更多  | 回车打开README | r重新加载')
  table.insert(lines, '')

  if #M.state.list == 0 then
    table.insert(lines, ' 暂无数据')
  else
    for _, item in ipairs(M.state.list) do
      local name = item.name or ''
      local star = tostring(item.stargazers_count or 0)
      local author = item.owner and item.owner.login or ''
      local desc = item.description or '无描述'
      desc = desc:sub(1, 60)

      local line = string.format(
        '  %-25s  %-18s ⭐ %-5s | %s',
        name,
        author,
        star,
        desc
      )
      table.insert(lines, line)
    end
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
end

function M.render_loading()
  local buf = M.state.buf
  if not buf or not api.nvim_buf_is_valid(buf) then return end
  
  local lines = {
    ' ⏳ 加载中... 从 GitHub 获取插件',
    '',
    ' (首次加载可能需要 5-10 秒)',
  }
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
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
  
  -- 添加重新加载快捷键
  vim.keymap.set('n', 'r', function()
    M.state.list = {}
    M.state.page = 1
    M.fetch()
  end, { buffer = buf, desc = '重新加载' })

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

vim.api.nvim_create_user_command("GithubMarket", function()
  require("nvim_market").open()
end, { desc = "启动 GithubMarket 插件" })

return M
