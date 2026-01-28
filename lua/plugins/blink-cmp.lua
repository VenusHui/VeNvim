return {
  -- 配置 blink.cmp 使用 LuaSnip
  {
    "saghen/blink.cmp",
    opts = {
      snippets = {
        preset = "luasnip",
        -- 自定义展开函数：展开新代码片段前退出之前的所有代码片段
        expand = function(snippet)
          local ls = require("luasnip")
          -- 退出所有活跃的代码片段
          while ls.get_active_snip() do
            ls.unlink_current()
          end
          ls.lsp_expand(snippet)
        end,
      },
      keymap = {
        preset = "default",
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        -- Enter: 接受补全（补全菜单可见时）
        ["<CR>"] = { "accept", "fallback" },
        -- Tab: 仅用于代码片段跳转
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      -- 命令行模式的补全配置
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<C-j>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<Tab>"] = { "accept", "fallback" },
        },
      },
    },
  },
}
