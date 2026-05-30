-- ==============================
-- 基础设置
-- ==============================
vim.opt.number = true          -- 显示绝对行号
vim.opt.relativenumber = false -- 关闭相对行号
vim.opt.mouse = 'a'            -- 鼠标支持
vim.opt.termguicolors = true   -- 真彩色（现代界面）
vim.opt.cursorline = true      -- 高亮当前行
vim.opt.autowrite = true       -- 自动保存
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.encoding = "utf-8"
vim.opt.fileencodings = "utf-8,ucs-bom,gb18030,gbk,gb2312,cp936"

vim.o.guifont = "JetBrains Mono NL:h14"

-- ==============================
-- 中文界面（Lang & 相关插件）
-- ==============================
vim.g.langmenu = 'zh_CN.UTF-8'
pcall(function() vim.cmd('language messages zh_CN.UTF-8') end)

-- ==============================
-- 全局快捷键
-- ==============================

-- F11 一键编译运行 C++
vim.keymap.set('n', '<F11>', function()
  vim.cmd('w')
  local file = vim.fn.expand('%')
  local out = vim.fn.expand('%:r')
  vim.cmd('!g++ "' .. file .. '" -o "' .. out .. '" -std=c++11 && ./"' .. out .. '"')
end, {desc = "编译并运行 C++ 文件 [F11]"})

-- F5 兼容“新版”一键编译
vim.keymap.set('n', '<F5>', function()
  local file = vim.fn.expand('%')
  local out = vim.fn.expand('%:r')
  vim.cmd('w')
  vim.cmd('!g++ -std=c++17 ' .. file .. ' -o ' .. out)
  vim.cmd('terminal ./' .. out)
  vim.cmd('startinsert')
end, {desc = "编译并运行 C++ 文件 [F5]"})

-- 标签页切换快捷键
vim.keymap.set('n', '<C-l>', ':bnext<CR>', {desc = "切换下一个标签"})
vim.keymap.set('n', '<C-h>', ':bprev<CR>', {desc = "切换上一个标签"})
vim.keymap.set('n', '<C-x>', ':bd<CR>', {desc = "关闭当前标签"})

-- ==============================
-- 全局系统剪贴板快捷键
-- ==============================
vim.keymap.set({ "n", "v", "i", "c" }, "<C-v>", function()
  if vim.fn.mode() == "i" or vim.fn.mode() == "c" then
    return vim.api.nvim_replace_termcodes("<C-r>+", true, true, true)
  else
    return '"+p'
  end
end, { noremap = true, expr = true, silent = true, desc = "全模式粘贴系统剪贴板" })

vim.keymap.set({ "n", "v", "i", "c" }, "<C-c>", function()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    return '"+y'
  else
    return ''
  end
end, { noremap = true, expr = true, silent = true, desc = "全模式复制到系统剪贴板" })

vim.keymap.set({ "n", "i", "c", "v" }, "<C-a>", function()
  return vim.api.nvim_replace_termcodes("<Esc>ggVG", true, true, true)
end, { noremap = true, expr = true, silent = true, desc = "全选" })

-- 如果想在 Insert 下额外支持 <C-a>/<C-c>/<C-v> 显式行为，也单独声明如下（可选）
 vim.keymap.set('i', '<C-a>', '<ESC>ggVG<CR>a', { desc = '全选' })
 vim.keymap.set('i', '<C-c>', '<ESC>"+y<CR>a', { desc = '复制' })
 vim.keymap.set('i', '<C-v>', '<C-r>+', { desc = '粘贴' })

-- ==============================
-- 插件管理器/插件列表
-- ==============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

vim.fn.chdir("E:/ERIC/subcode")

require("lazy").setup({
  -- 主题
  { "folke/tokyonight.nvim", priority = 1000, config = function() vim.cmd("colorscheme tokyonight-storm") end },

  -- 顶部多标签栏
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup{
        options = {
          mode = "buffers",
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          indicator = {style = "icon"},
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "󰅖",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 18,
          max_prefix_length = 15,
          truncate_names = true,
          tab_size = 18,
          diagnostics = false,
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
        }
      }
    end
  },

  {
  "Abdi-6666666/nvim_market",
  config = function()
    -- 按需写你的Lua插件初始化逻辑
    vim.keymap.set('n', '<leader>m', function()
      require('nvim_market').open()
    end, { desc = '打开 Neovim 插件市场' })
  end,
},

  -- 文件树
  { "nvim-tree/nvim-tree.lua", config = function()
    require("nvim-tree").setup()
    vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = "切换目录树 [<leader>e]" })
  end },

  -- 终端
  { "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        hidden = true,
        shade_terminals = true,
        shell = vim.o.shell,
      })
      vim.keymap.set({"n", "t"}, "<A-t>", "<cmd>ToggleTerm<CR>", { desc = "Toggle 终端 [Alt+t]" })
    end
  },

  -- Copilot 智能增强
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      vim.g.copilot_enabled = true
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_auto_trigger = true
      vim.g.copilot_suggestion_delay = 100
      vim.g.copilot_version = "latest"
      vim.g.copilot_filetypes = {
        ["*"] = false,
        c = true, cpp = true, lua = true, python = true,
        javascript = true, typescript = true, html = true,
        css = true, markdown = true
      }
      vim.keymap.set("i", "<C-Right>", 'copilot#Accept("")', {expr=true,silent=true,noremap=true})
      vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", {silent=true})
      vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", {silent=true})
      vim.keymap.set("i", "<C-Left>", "<Plug>(copilot-dismiss)", {silent=true})
      vim.keymap.set("i", "<M-CR>", 'copilot#Accept("\\<CR>")', {expr=true,silent=true,noremap=true})
    end
  },

  -- 丝滑光标拖尾
  {
    "sphamba/smear-cursor.nvim",
    config = function()
      require("smear_cursor").setup({
        smear_color = "#7aa2f7",
        trailing_stretch = 0.8,
        slowdown_factor = 0.7,
      })
    end
  },

  -- 自动补全（nvim-cmp为主，与blink.cmp择一用，根据需求可补充）
  {
    "hrsh7th/nvim-cmp",  -- 自动补全本体
    dependencies = {
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-buffer" },
      -- 可加 cmp-path, cmp-snippet 等
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        -- 你的补全配置...
      })
      -- cmdline (:)
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'cmdline' } }
      })
      -- search (/)
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'buffer' } }
      })
    end
  },

  -- 文件图标依赖
  {"nvim-tree/nvim-web-devicons"},

  -- lualine 状态栏
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
      })
    end,
  },

  -- 括号自动补全
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- 插件市场功能
  -- 若未有插件"plugins.nvim_market"，可注释掉下一块
   --{
   --  "plugins.nvim_market",
   --  config = function()
   --   vim.keymap.set('n', '<leader>pm', function()
   --      require('plugins.nvim_market').open()
   --  end, { desc = '打开 Neovim 插件市场' })
   --  end,
   --},

  -- 中文帮助文档（需本地有中文Vim翻译包）
  {
    "yianwillis/vimcdoc",
    config = function()
      vim.g.vim_help_language = "cn"
    end,
  },
})

-- ==============================
-- 自动启动项
-- ==============================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("NvimTreeToggle")
    vim.cmd("ToggleTerm")
    if vim.fn.exists(":Copilot") == 2 then
      vim.cmd("Copilot enable") -- 启动Copilot（如已支持）
    end
  end
})