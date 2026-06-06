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

-- F12 一键编译运行 C++
vim.keymap.set('n', '<F12>', function()
  vim.cmd('w')
  local file = vim.fn.expand('%')
  local out = vim.fn.expand('%:r')
  vim.cmd('!g++ "' .. file .. '" -o "' .. out .. '" -std=c++11 && start cmd /k "' .. out .. ' & pause"')
end, {desc = "编译并运行 C++ 文件 [F12]"})

-- F11 兼容"新版"一键编译
vim.keymap.set('n', '<F11>', function()
  local file = vim.fn.expand('%')
  local out = vim.fn.expand('%:r')
  vim.cmd('w')
  vim.cmd('!g++ -std=c++11 ' .. file .. ' -o ' .. out)
  if vim.fn.executable(out) == 1 then
    vim.cmd('terminal ' .. out)
  end
  vim.cmd('startinsert')
end, {desc = "编译并运行 C++ 文件 [F5]"})

-- 标签页切换快捷键
vim.keymap.set('n', '<C-l>', ':bnext<CR>', {desc = "切换下一个标签"})
vim.keymap.set('n', '<C-h>', ':bprev<CR>', {desc = "切换上一个标签"})

-- 关闭当前标签（改进版）
vim.keymap.set('n', '<C-x>', function()
  vim.cmd('bd')
end, {desc = "关闭当前标签"})

-- ==============================
-- 全局系统剪贴板快捷键
-- ==============================
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { noremap = true, desc = "复制到系统剪贴板" })
vim.keymap.set({ "n", "v" }, "<C-v>", '"+p', { noremap = true, desc = "粘贴系统剪贴板" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { noremap = true, desc = "粘贴系统剪贴板" })
vim.keymap.set("c", "<C-v>", "<C-r>+", { noremap = true, desc = "粘贴系统剪贴板" })

-- 全选
vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, desc = "全选" })
vim.keymap.set("i", "<C-a>", "<ESC>ggVG", { noremap = true, desc = "全选" })
vim.keymap.set("c", "<C-a>", "<C-u>", { noremap = true, desc = "全选命令行" })

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

  -- ==============================
  -- 顶部多标签栏
  -- ==============================
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
        indicator = {
          icon = '▎',
          style = 'icon'
        },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '󰅖',
        left_trunc_marker = '󰀶',
        right_trunc_marker = '󰀷',
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 20,
        diagnostics = "nvim_lsp",  -- 显示诊断信息
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        separator_style = "thick",  -- 👈 改成 thick（更粗的分隔符）
        enforce_regular_tabs = false,
        always_show_bufferline = true,
      },
      -- highlights = require("catppuccin.groups.integrations.bufferline").get(),  -- TeraFox 主题集成
    }
  end
},
  -- ==============================
  -- 自定义插件市场
  -- ==============================
  {
    "Abdi-6666666/nvim_market",
    branch = 'fix/improve-api-handling',
    config = function()
      vim.keymap.set('n', '<leader>m', function()
        require('nvim_market').open()
      end, { desc = '打开 Neovim 插件市场' })
    end,
  },

  -- ==============================
  -- 文件树
  -- ==============================
  { 
    "nvim-tree/nvim-tree.lua", 
    config = function()
      require("nvim-tree").setup({
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
      })
      vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = "切换目录树 [<leader>e]" })
    end 
  },

  -- ==============================
  -- 终端
  -- ==============================
  { 
    "akinsho/toggleterm.nvim",
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

  -- ==============================
  -- Copilot 智能增强
  -- ==============================
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

  -- ==============================
  -- 丝滑光标拖尾
  -- ==============================
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

  -- ==============================
  -- 自动补全
  -- ==============================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })

      -- cmdline (:)
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'cmdline' }
        })
      })

      -- search (/)
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
    end
  },

  -- ==============================
  -- 文件图标依赖
  -- ==============================
  "nvim-tree/nvim-web-devicons",

  -- ==============================
  -- 状态栏
  -- ==============================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { 
          theme = "terafox",
          globalstatus = true,
        },
      })
    end,
  },

  -- ==============================
  -- 括号自动补全
  -- ==============================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          lua = {'string'},
          javascript = {'template_string'},
        }
      })
    end,
  },

  {
  "EdenEast/nightfox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nightfox").setup({
      options = {
        transparent = true,           -- 背景透明
--        terminal_colors = true,       -- 启用终端颜色
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
          strings = "NONE",
        },
      }
    })
    vim.cmd("colorscheme terafox")
  end
},

  -- ==============================
  -- VSCode风格命令面板
  -- ==============================
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "LinArcX/telescope-command-palette.nvim"
    },
    config = function()
      require("telescope").setup({
        extensions = {
          command_palette = {
            { "文件",
              { "保存文件", ":w" },
              { "关闭文件", ":q" },
              { "保存全部", ":wa" },
              { "退出", ":qa" },
            },
            { "编辑",
              { "撤销", ":undo" },
              { "重做", ":redo" },
              { "全选", ":normal ggVG" },
            },
            { "常用设置",
              { "打开配置文件", ":e $MYVIMRC" },
              { "重新加载配置", ":so $MYVIMRC" },
            },
          },
        },
      })
      require("telescope").load_extension("command_palette")
      vim.keymap.set('n', '<leader>p', '<cmd>Telescope command_palette<CR>', { desc = "命令面板 [<leader>p]" })
    end,
  },

  -- ==============================
  -- 美观弹窗通知
  -- ==============================
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        stages = "slide",
        timeout = 2000,
        background_colour = "#1a1b26",
        render = "default",
        top_down = false,
      })
      vim.notify = require("notify")
    end,
  },

  -- ==============================
  -- 仪表板（启动页）
  -- ==============================
  {
    "nvimdev/dashboard-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local db = require('dashboard')
      
      db.setup({
        theme = 'hyper',
        config = {
          week_header = {
            enable = true,
          },
          header = {
            '',
            '',
            ' ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
            ' ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
            ' ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
            ' ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
            ' ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
            ' ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
            '',
            '',
          },
          
          shortcut = {
            {
              desc = '󰊳 Recent files',
              group = '@property',
              action = 'Telescope oldfiles',
              key = 'r'
            },
            {
              desc = '󰈙 Find file',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f'
            },
            {
              desc = '󰈭 Find word',
              group = 'Label',
              action = 'Telescope live_grep',
              key = 'g'
            },
            {
              desc = '󰣇 File tree',
              group = '@text',
              action = 'NvimTreeToggle',
              key = 'e'
            },
            {
              desc = '󰋚 Config',
              group = 'Function',
              action = 'e $MYVIMRC',
              key = 'c'
            },
            {
              desc = '󰗼 Quit',
              group = 'Function',
              action = 'qa',
              key = 'q'
            },
          },
          
          project = {
            enable = true,
            limit = 8,
            icon = '   ',
            label = ' Recent Project',
            action = 'Telescope find_files cwd='
          },
          
          mru = {
            enable = true,
            limit = 10,
            icon = '   ',
            label = ' Recent Files',
            cwd_only = false,
          },
          
          footer = {
            '',
            '⚡ Eric Coding | Powered by Neovim',
          }
        }
      })
    end
  },

  -- ==============================
  -- 快捷键提示（which-key）
  -- ==============================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      
      require("which-key").setup({
        window = {
          border = "rounded",
          margin = {1, 0, 1, 0},
          padding = {2, 2, 2, 2},
        },
        icons = {
          separator = "➜",
          group = "+",
        },
        layout = {
          align = "center"
        }
      })

      require("which-key").register({
        ["<leader>"] = {
          p = "命令面板",
          w = "保存文件",
          m = "插件市场",
          e = "文件树",
        }
      })
    end
  },
})

-- ==============================
-- 保存快捷键
-- ==============================
vim.keymap.set('n', '<leader>w', function()
  vim.cmd('w')
  vim.notify("✓ 保存成功", "info", { title = "提示" })
end, { desc = "保存文件并通知" })

-- ==============================
-- Dashboard 自动显示逻辑
-- ==============================
local dashboard_check_timer = nil
local showing_dashboard = false

-- 检查是否应该显示 dashboard
local function check_and_show_dashboard()
  -- 如果已经在显示 dashboard，不要重复显示
  if showing_dashboard then
    return
  end

  -- 获取当前 buffer 信息
  local current_buf = vim.fn.bufnr("%")
  local buf_name = vim.fn.bufname(current_buf)
  local buf_type = vim.api.nvim_buf_get_option(current_buf, 'buftype')
  
  -- 统计已列出的有效 buffer 数量
  local listed_bufs = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.fn.bufname(buf)
      local btype = vim.api.nvim_buf_get_option(buf, 'buftype')
      local blisted = vim.api.nvim_buf_get_option(buf, 'buflisted')
      
      -- 只计算已列出、非空的 buffer
      if blisted and btype == '' and name ~= '' then
        listed_bufs = listed_bufs + 1
      end
    end
  end
  
  -- 如果没有有效的 buffer 了，且当前不是 dashboard，显示 dashboard
  if listed_bufs == 0 and buf_name:find('dashboard', 1, true) == nil then
    showing_dashboard = true
    vim.cmd('Dashboard')
    -- 延迟重置标志
    vim.defer_fn(function()
      showing_dashboard = false
    end, 500)
  end
end

-- Neovide 启动时显示 dashboard
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.defer_fn(function()
        showing_dashboard = true
        vim.cmd("Dashboard")
        vim.defer_fn(function()
          showing_dashboard = false
        end, 500)
      end, 100)
    end
  end,
  once = true,
})

-- 监听 buffer 切换事件
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- 清除旧计时器
    if dashboard_check_timer then
      vim.fn.timer_stop(dashboard_check_timer)
    end
    -- 延迟检查，避免频繁触发
    dashboard_check_timer = vim.fn.timer_start(200, function()
      check_and_show_dashboard()
    end)
  end,
})

-- ==============================
-- 性能优化
-- ==============================
vim.opt.updatetime = 100
vim.opt.hidden = true
vim.opt.swapfile = false

vim.api.nvim_create_user_command("GithubMarket", function()
  require("nvim_market").open()
end, { desc = "启动 GithubMarket 插件" })
