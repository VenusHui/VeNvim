return {
  -- 禁用 neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  -- 配置 snacks explorer 显示被 gitignore 隐藏的文件
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
