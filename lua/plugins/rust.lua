return {
  -- ==========================
  -- Mason: 确保 Rust 工具安装
  -- ==========================
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "codelldb", -- 调试器（与 C++ 共用）
        "taplo", -- TOML LSP（用于 Cargo.toml）
      })
    end,
  },

  -- ==========================
  -- Treesitter: Rust 语法高亮
  -- ==========================
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust", "ron", "toml" })
    end,
  },

  -- ==========================
  -- LSP: 禁止 lspconfig 启动 rust-analyzer
  -- 由 rustaceanvim 统一管理
  -- ==========================
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {},
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
      setup = {
        rust_analyzer = function()
          return true -- 阻止 lspconfig 设置 rust-analyzer，交给 rustaceanvim
        end,
      },
    },
  },

  -- ==========================
  -- rustaceanvim: Rust 增强支持
  -- ==========================
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    opts = {
      server = {
        on_attach = function(_, bufnr)
          -- Rust 专用快捷键
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action (Rust)", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
          vim.keymap.set("n", "<leader>rr", function()
            vim.cmd.RustLsp("runnables")
          end, { desc = "运行 Rust", buffer = bufnr })
          vim.keymap.set("n", "<leader>rt", function()
            vim.cmd.RustLsp("testables")
          end, { desc = "运行 Rust 测试", buffer = bufnr })
          vim.keymap.set("n", "<leader>re", function()
            vim.cmd.RustLsp("expandMacro")
          end, { desc = "展开宏 (Rust)", buffer = bufnr })
          vim.keymap.set("n", "<leader>rc", function()
            vim.cmd.RustLsp("openCargo")
          end, { desc = "打开 Cargo.toml", buffer = bufnr })
          vim.keymap.set("n", "<leader>rp", function()
            vim.cmd.RustLsp("parentModule")
          end, { desc = "父模块 (Rust)", buffer = bufnr })
          vim.keymap.set("n", "<leader>rd", function()
            vim.cmd.RustLsp("renderDiagnostic")
          end, { desc = "渲染诊断 (Rust)", buffer = bufnr })
          vim.keymap.set("n", "<leader>rv", function()
            vim.cmd.RustLsp({ "moveItem", "down" })
          end, { desc = "下移项目 (Rust)", buffer = bufnr })
          vim.keymap.set("n", "<leader>rV", function()
            vim.cmd.RustLsp({ "moveItem", "up" })
          end, { desc = "上移项目 (Rust)", buffer = bufnr })
          vim.keymap.set("n", "J", function()
            vim.cmd.RustLsp("joinLines")
          end, { desc = "合并行 (Rust)", buffer = bufnr })
          vim.keymap.set("n", "K", function()
            vim.cmd.RustLsp({ "hover", "actions" })
          end, { desc = "悬停操作 (Rust)", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- 使用 clippy 作为检查工具
            checkOnSave = true,
            check = {
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            -- Inlay Hints 配置
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = {
                enable = true,
                minLines = 25,
              },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never" },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },

  -- ==========================
  -- crates.nvim: Cargo.toml 依赖管理
  -- ==========================
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = false },
        crates = {
          enabled = true,
          max_results = 8,
          min_chars = 3,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
    keys = {
      {
        "<leader>rcu",
        function()
          require("crates").upgrade_all_crates()
        end,
        desc = "升级所有 Crate",
      },
      {
        "<leader>rcU",
        function()
          require("crates").update_all_crates()
        end,
        desc = "更新所有 Crate",
      },
      {
        "<leader>rci",
        function()
          require("crates").show_crate_popup()
        end,
        desc = "显示 Crate 信息",
      },
      {
        "<leader>rcf",
        function()
          require("crates").show_features_popup()
        end,
        desc = "显示 Crate Features",
      },
      {
        "<leader>rcd",
        function()
          require("crates").show_dependencies_popup()
        end,
        desc = "显示 Crate 依赖",
      },
    },
  },

  -- ==========================
  -- nvim-dap: Rust 调试配置
  -- ==========================
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      if not dap.configurations.rust then
        dap.configurations.rust = {
          {
            name = "Launch",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("可执行文件路径: ", vim.fn.getcwd() .. "/target/debug/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
          {
            name = "Attach to process",
            type = "codelldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
          },
        }
      end
    end,
  },

  -- ==========================
  -- conform.nvim: 使用 rustfmt 格式化
  -- ==========================
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },
}
