return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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
              desc = "Show crate documentation",
            },
          },
        },
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      opts.server = opts.server or {}
      local lazyvim_on_attach = opts.server.on_attach
      opts.server.on_attach = function(client, bufnr)
        if lazyvim_on_attach then
          lazyvim_on_attach(client, bufnr)
        end

        local function rust_map(lhs, command, desc)
          vim.keymap.set("n", lhs, function()
            vim.cmd.RustLsp(command)
          end, { buffer = bufnr, desc = desc })
        end

        rust_map("<leader>rr", "runnables", "Run Rust target")
        rust_map("<leader>rt", "testables", "Run Rust test")
        rust_map("<leader>re", "expandMacro", "Expand Rust macro")
        rust_map("<leader>rc", "openCargo", "Open Cargo.toml")
        rust_map("<leader>rp", "parentModule", "Open parent module")
        rust_map("<leader>rd", "renderDiagnostic", "Render Rust diagnostic")
        rust_map("J", "joinLines", "Join Rust lines")
        rust_map("K", { "hover", "actions" }, "Rust hover actions")

        vim.keymap.set("n", "<leader>rv", function()
          vim.cmd.RustLsp({ "moveItem", "down" })
        end, { buffer = bufnr, desc = "Move Rust item down" })
        vim.keymap.set("n", "<leader>rV", function()
          vim.cmd.RustLsp({ "moveItem", "up" })
        end, { buffer = bufnr, desc = "Move Rust item up" })
      end

      opts.server.default_settings = opts.server.default_settings or {}
      local settings = opts.server.default_settings["rust-analyzer"] or {}
      opts.server.default_settings["rust-analyzer"] = vim.tbl_deep_extend("force", settings, {
        cargo = {
          allFeatures = false,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        checkOnSave = true,
        check = {
          command = "clippy",
          extraArgs = { "--no-deps" },
        },
        procMacro = { enable = true },
        inlayHints = {
          bindingModeHints = { enable = false },
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
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
      })
    end,
  },

  {
    "Saecki/crates.nvim",
    opts = {
      completion = {
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
        desc = "Upgrade all crates",
      },
      {
        "<leader>rcU",
        function()
          require("crates").update_all_crates()
        end,
        desc = "Update all crates",
      },
      {
        "<leader>rci",
        function()
          require("crates").show_crate_popup()
        end,
        desc = "Show crate information",
      },
      {
        "<leader>rcf",
        function()
          require("crates").show_features_popup()
        end,
        desc = "Show crate features",
      },
      {
        "<leader>rcd",
        function()
          require("crates").show_dependencies_popup()
        end,
        desc = "Show crate dependencies",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },
}
