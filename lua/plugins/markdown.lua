return {
  {
    -- 在编辑 buffer 内实时渲染 markdown（标题、代码块、表格、checkbox 等）
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- LazyVim 已内置 mini.icons / nvim-web-devicons，图标会自动识别，无需额外声明
    },
    opts = {},
    config = function(_, opts)
      local plugin = require("render-markdown")
      plugin.setup(opts)
      -- markdown buffer 内开关渲染
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("render_markdown_keymaps", { clear = true }),
        pattern = "markdown",
        callback = function(event)
          vim.keymap.set("n", "<leader>md", function()
            plugin.toggle()
          end, { buffer = event.buf, desc = "Toggle markdown render" })
        end,
      })
    end,
  },
}
