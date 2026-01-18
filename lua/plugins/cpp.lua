return {
  -- ==========================
  -- LSP 和代码智能提示
  -- ==========================

  -- 确保 clangd 安装（通过 Mason）
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clangd", -- C/C++ LSP
        "clang-format", -- 代码格式化
        "codelldb", -- 调试器
        "cpplint", -- C++ 代码检查
        "cpptools", -- C++ 工具
      })
    end,
  },

  -- ==========================
  -- C++ 专用插件
  -- ==========================

  -- C/C++ 增强语法高亮
  {
    "jackguo380/vim-lsp-cxx-highlight",
    event = "BufRead *.c,*.cpp,*.h,*.hpp",
  },

  -- CMake 支持
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "cpp", "c" },
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_build_type = "Debug",
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_console_size = 10,
      cmake_show_console = "always",
    },
  },

  -- 现代 C++ 特性高亮
  {
    "bfrg/vim-cpp-modern",
    event = "BufRead *.cpp,*.hpp",
  },

  -- Doxygen 注释生成
  {
    "vim-scripts/DoxygenToolkit.vim",
    keys = {
      { "<leader>cd", "<cmd>Dox<cr>", desc = "Generate Doxygen comment" },
    },
    config = function()
      vim.g.DoxygenToolkit_commentType = "C++"
      vim.g.DoxygenToolkit_briefTag_pre = "\\brief "
      vim.g.DoxygenToolkit_paramTag_pre = "\\param "
      vim.g.DoxygenToolkit_returnTag = "\\return "
    end,
  },

  -- 头文件/源文件快速切换
  {
    "derekwyatt/vim-fswitch",
    keys = {
      { "<leader>ch", "<cmd>FSHere<cr>", desc = "Switch header/source" },
    },
    config = function()
      vim.g.fswitchlocs = "reg:/src/include/,reg:/include/src/,ifrel:|/src/|../include|,ifrel:|/include/|../src|"
    end,
  },

  -- ==========================
  -- 调试相关
  -- ==========================

  -- 调试界面增强
  {
    "ofirgall/goto-breakpoints.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    keys = {
      {
        "]b",
        function()
          require("goto-breakpoints").next()
        end,
        desc = "Next breakpoint",
      },
      {
        "[b",
        function()
          require("goto-breakpoints").prev()
        end,
        desc = "Prev breakpoint",
      },
    },
  },

  -- DAP 配置
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
        },
      }
      dap.configurations.c = dap.configurations.cpp
    end,
  },

  -- ==========================
  -- 代码分析和重构
  -- ==========================

  -- Clangd 扩展和配置
  {
    "p00f/clangd_extensions.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "c", "cpp", "objc", "objcpp" },
    config = function()
      local clangd_ext = require("clangd_extensions")
      local lspconfig = require("lspconfig")

      -- 创建 compile_flags.txt 的辅助函数
      local function create_compile_flags(root_dir)
        local compile_flags = root_dir .. "/compile_flags.txt"
        if vim.fn.filereadable(compile_flags) == 1 then
          return false
        end

        local flags_content = "-I/usr/local/include\n"
        if vim.fn.has("mac") == 1 then
          flags_content = flags_content .. "-I/opt/homebrew/include\n"
          local xcode_path = vim.fn.system("xcode-select -p 2>/dev/null"):gsub("%s+", "")
          if xcode_path and xcode_path ~= "" then
            flags_content = flags_content .. "-I" .. xcode_path .. "/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1\n"
            flags_content = flags_content .. "-I" .. xcode_path .. "/usr/include\n"
          end
        elseif vim.fn.has("unix") == 1 then
          flags_content = flags_content .. "-I/usr/include/c++\n"
          flags_content = flags_content .. "-I/usr/local/include\n"
        end

        local file = io.open(compile_flags, "w")
        if file then
          file:write(flags_content)
          file:close()
          return true
        end
        return false
      end

      local clangd_capabilities = vim.lsp.protocol.make_client_capabilities()
      clangd_capabilities.offsetEncoding = { "utf-16" }

      clangd_ext.setup({
        server = {
          capabilities = clangd_capabilities,
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=/usr/bin/clang++",
            "--query-driver=/usr/bin/clang",
            "--query-driver=/usr/local/bin/clang++",
            "--query-driver=/opt/homebrew/bin/clang++",
          },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
            semanticHighlighting = true,
          },
          root_dir = function(fname)
            return lspconfig.util.root_pattern("compile_commands.json", "build/compile_commands.json", ".git", "compile_flags.txt")(fname)
              or vim.fn.getcwd()
          end,
        },
        extensions = {
          inlay_hints = { inline = true },
          ast = {
            role_icons = {
              type = "🄣",
              declaration = "🄓",
              expression = "🄔",
              statement = ";",
              specifier = "🄢",
              ["template argument"] = "🆃",
            },
          },
        },
      })

      -- 自动创建 compile_flags.txt
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            local filetype = vim.bo[args.buf].filetype
            if not (filetype == "c" or filetype == "cpp" or filetype == "objc" or filetype == "objcpp") then
              return
            end

            local root_dir = client.config.root_dir or vim.fn.getcwd()
            local compile_commands = root_dir .. "/compile_commands.json"
            local build_compile_commands = root_dir .. "/build/compile_commands.json"

            if vim.fn.filereadable(compile_commands) == 0
              and vim.fn.filereadable(build_compile_commands) == 0
            then
              if create_compile_flags(root_dir) then
                vim.notify("已自动创建 compile_flags.txt，请运行 :LspRestart clangd", vim.log.levels.INFO)
              end
            end
          end
        end,
      })

      -- 手动创建命令
      vim.api.nvim_create_user_command("ClangdCreateFlags", function()
        local cwd = vim.fn.getcwd()
        if create_compile_flags(cwd) then
          vim.notify("已创建 compile_flags.txt，请运行 :LspRestart clangd", vim.log.levels.INFO)
        else
          vim.notify("compile_flags.txt 已存在或创建失败", vim.log.levels.WARN)
        end
      end, { desc = "创建 compile_flags.txt 以支持 bits/stdc++.h" })
    end,
  },

  -- C++ 模板调试（增强跳转定义）
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    ft = { "cpp", "c" },
    dependencies = { "p00f/clangd_extensions.nvim" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            client.handlers["textDocument/definition"] = require("omnisharp_extended").handler
          end
        end,
      })
    end,
  },

  -- 配置 blink.cmp 使用 LuaSnip
  {
    "saghen/blink.cmp",
    opts = {
      snippets = { preset = "luasnip" },
    },
  },

  -- 加载自定义代码片段
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      -- 加载自定义 Lua snippets（LazyVim 已处理 friendly-snippets）
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
      })

      -- 配置 Tab 键：在代码片段中跳转，否则正常缩进
      vim.keymap.set("i", "<Tab>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        else
          -- 不在代码片段中，使用 feedkeys 插入 Tab 字符用于缩进
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, { silent = true, desc = "LuaSnip: 跳转或缩进" })

      vim.keymap.set("i", "<S-Tab>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        else
          -- 不在代码片段中，使用 feedkeys 插入 Shift+Tab
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
        end
      end, { silent = true, desc = "LuaSnip: 返回上一个位置" })

      -- 选择模式下的映射
      vim.keymap.set("s", "<Tab>", function()
        if ls.jumpable(1) then
          ls.jump(1)
        end
      end, { silent = true, desc = "LuaSnip: 跳转到下一个位置" })

      vim.keymap.set("s", "<S-Tab>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "LuaSnip: 跳转到上一个位置" })
    end,
  },
}
