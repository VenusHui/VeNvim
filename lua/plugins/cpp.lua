return {
  -- Extend LazyVim's clangd extra with the local compiler and project markers.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=/usr/bin/g++,/usr/bin/gcc",
            "--log=error",
          },
          root_markers = {
            "compile_commands.json",
            "compile_flags.txt",
            "CMakeLists.txt",
            "Makefile",
            "meson.build",
            "build.ninja",
            ".git",
          },
        },
      },
    },
  },

  {
    "p00f/clangd_extensions.nvim",
    opts = {
      inlay_hints = { inline = false },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
      },
    },
  },

  {
    "vim-scripts/DoxygenToolkit.vim",
    keys = {
      { "<leader>cd", "<cmd>Dox<cr>", desc = "Generate Doxygen comment" },
    },
    init = function()
      vim.g.DoxygenToolkit_commentType = "C++"
      vim.g.DoxygenToolkit_briefTag_pre = "\\brief "
      vim.g.DoxygenToolkit_paramTag_pre = "\\param "
      vim.g.DoxygenToolkit_returnTag = "\\return "
    end,
  },

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
        desc = "Previous breakpoint",
      },
    },
  },
}
