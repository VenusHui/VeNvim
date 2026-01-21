return {
  -- 配置 blink.cmp 使用 LuaSnip
  {
    "saghen/blink.cmp",
    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "default",
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        -- Tab: 接受补全 -> 代码片段跳转 -> 正常缩进
        ["<Tab>"] = { "snippet_forward", "accept", "fallback" },
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
